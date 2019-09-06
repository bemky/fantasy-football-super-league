require 'net/http'

class HTTP::Connection
  
  def connect!
    @http_connection = Net::HTTP.new(@host.host, @host.port)
    @http_connection.max_retries         = 0
    @http_connection.open_timeout        = 5
    @http_connection.read_timeout        = 30
    @http_connection.write_timeout       = 5
    @http_connection.ssl_timeout         = 5
    @http_connection.keep_alive_timeout  = 30
    @http_connection.use_ssl             = @host.scheme == 'https'
    @http_connection.start
  end
  
  def disconnect!
    if @http_connection
      @http_connection.finish if @http_connection.active?
      @http_connection = nil
    end
  end
  
  def reconnect!
    disconnect!
    connect!
  end

  def active?
    !@http_connection.nil? && @http_connection.active?
  end
  
  def connection
    reconnect! if !active?
    @http_connection
  end
  
  def preflight(request)
  end
  
  def send_request(request, body=nil, retries: 0, close_connection: false, &block)
    preflight(request)
    
    request.body = (body.is_a?(String) ? body : JSON.generate(body)) if body
    return_value = nil
    
    connection.set_debug_output($stdout)
    
    connection.request(request) do |response|
      close_connection = response['Connection'] == 'close'

      case response
      when Net::HTTPSuccess
        if block_given?
          return_value = yield(response)
        else
          return_value = response.body
          return_value = JSON.parse(return_value) if response['Content-Type'].split(';').first == 'application/json'
        end
      else
        raise "Error connecting to #{@host}#{request.path}; recieved #{response.code}"
      end
    end
    disconnect! if close_connection

    return_value
  end

  def get(path, access_token, params={}, &block)
    request = Net::HTTP::Get.new(@host.path.delete_suffix('/') + '/' + path.delete_prefix('/') + '?' + params.to_param)
    request['Authorization'] = "Bearer #{access_token}"
    send_request(request, nil, &block)
  end
  
  def post(path, access_token, params='', &block)
    params ||= ''
    request = Net::HTTP::Post.new(@host.path.delete_suffix('/') + '/' + path.delete_prefix('/'))
    request['Authorization'] = "Bearer #{access_token}"
    request.set_form_data(params)

    send_request(request, nil, &block)
  end
  
end


class Yahoo < HTTP::Connection
  include Singleton

  attr_reader :client_id, :client_secret, :oauth_url, :api_url
  
  def initialize
    @client_id = Rails.application.secrets[:yahoo].try(:[], :client_id)
    @client_secret = Rails.application.secrets[:yahoo].try(:[], :client_secret)
    @oauth_url = Rails.application.secrets[:yahoo].try(:[], :oauth_url)
    @host = URI.parse(Rails.application.secrets[:yahoo].try(:[], :api_url))
  end
  
  def oauth_url
    
    @oauth_url + "/oauth2/request_auth?" + {
      client_id: @client_id,
      redirect_uri: Rails.application.config.root_url,
      response_type: 'code'
    }.to_param
  end

  def authenticate(params)
    return "" unless params[:code] || params[:refresh_token]
    
    Net::HTTP.start(URI.parse(@oauth_url).host, 443, use_ssl: true) do |http|
      request = Net::HTTP::Post.new('/oauth2/get_token')
      
      request.set_form_data(params.merge({
        client_id:      @client_id,
        client_secret:  @client_secret,
        redirect_uri: Rails.application.config.root_url,
        grant_type: 'authorization_code'
      }))
      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          response = JSON.parse(response.body)
          return response
        else
          raise RuntimeError, "Invalid response from Yahoo #{@oauth_url}; recieved #{response.code}"
        end
      end
    end
  end

  # Delegates all uncauge class method calls to the singleton
  def self.method_missing(method, *args, &block)
    instance.__send__(method, *args, &block)
  end

end

