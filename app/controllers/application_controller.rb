class ApplicationController < ActionController::Base

  before_action :set_root_url
  before_action :set_access_token

  def set_root_url
    Rails.application.config.root_url = root_url
  end
  
  def set_access_token
    
    start_time = Time.now
    if session[:access_token] && session[:access_token_expires_at] <= Time.now
      response = Yahoo.authenticate(refresh_token: session[:refresh_token], grant_type: 'refresh_token')
      session[:access_token]             = response["access_token"]
      session[:access_token_expires_at]  = start_time + response["expires_in"] - 30
      session[:refresh_token]            = response["refresh_token"]
    end
    if params[:code]
      response = Yahoo.authenticate(code: params[:code])
      session[:access_token]             = response["access_token"]
      session[:access_token_expires_at]  = start_time + response["expires_in"] - 30
      session[:refresh_token]            = response["refresh_token"]
      redirect_to '/'
      return
    end
    
    return session[:access_token] if session[:access_token]
    
    redirect_to Yahoo.oauth_url
  end
  
  def index
    leagues = %w(1101180 829718 1057144 808962)
    response = Yahoo.get("/leagues;league_keys=#{leagues.map{|x| "390.l.#{x}"}.join(",")};out=standings,scoreboard", session[:access_token]);
    @data = Hash.from_xml(response)
    
    @week_number = 0;
    @standings = @data['fantasy_content']['leagues']['league'].map do |league|
      teams = league['standings']['teams']["team"].map do |team|
        {
          name: team['name'],
          logo: team['team_logos']['team_logo']['url'],
          id: team['team_id'],
          league_id: league['league_id'],
          league: league['name'],
          points: team['team_points']['total'].to_i,
          manager: team['managers']['manager'].kind_of?(Array) ? team['managers']['manager'].map do |manager|
            manager.try(:[], 'nickname')
          end.join(", ") : team['managers']['manager']['nickname']
        }
      end
      @week_number = league['scoreboard']['week']
      league['scoreboard']['matchups']['matchup'].each do |matchup|
        matchup['teams']['team'].each do |team|
          t = teams.find{|x| x[:id] == team["team_id"]}
          t[:week_points] = team['team_points']['total'].to_i
        end
      end
      teams
    end.flatten.sort_by{|x| x[:points]}.reverse
  end
  
  def raw
    index
    render json: @data
  end
  
end
