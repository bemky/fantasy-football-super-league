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
          points: team['team_points']['total'].to_f,
          manager: manager(team, league)
        }
      end
      @week_number = league['scoreboard']['week']
      league['scoreboard']['matchups']['matchup'].each do |matchup|
        matchup['teams']['team'].each do |team|
          t = teams.find{|x| x[:id] == team["team_id"]}
          t[:week_points] = team['team_points']['total'].to_f
        end
      end
      teams
    end.flatten.sort_by{|x| x[:points]}.reverse
  end
  
  def raw
    index
    render json: @data
  end
  
  def manager(team, league)
    mapping = {
      '1101180.1': 'Patrick',
      '808962.11': 'Kunal',
      '808962.10': 'Ryan',
      '808962.9': 'Tanner',
      '808962.8': 'Paul',
      '808962.7': 'Brent S',
      '808962.6': 'Maxwell',
      '808962.5': 'David',
      '808962.4': 'William',
      '808962.3': 'kareem',
      '808962.2': 'Hillel',
      '808962.1': 'Raymond',
      '1057144.12': 'John',
      '1057144.11': 'Miyagi',
      '1057144.10': 'Sergey',
      '1057144.9': 'Andrew',
      '1057144.8': 'Not Paying, ravi',
      '1057144.7': '-- hidden --',
      '1057144.6': 'Chris',
      '1057144.5': 'Justin',
      '1057144.4': 'Anthony',
      '1057144.3': 'Angela',
      '1057144.2': 'Taylor',
      '1057144.1': 'Ryan',
      '829718.12': 'Chris',
      '829718.11': 'Jim',
      '829718.10': 'Nathan',
      '829718.9': 'Stephen',
      '829718.8': 'Jerry Won',
      '829718.7': 'Roshni, Kerianne',
      '829718.6': 'kevin',
      '829718.5': 'Ray',
      '829718.4': 'Ben K',
      '829718.3': 'Riley',
      '829718.2': 'Paul Duca',
      '829718.1': 'Chris',
      '1101180.12': 'david',
      '1101180.11': 'Eug Lee',
      '1101180.10': 'Vik',
      '1101180.9': 'AllanT',
      '1101180.8': 'David',
      '1101180.7': 'Ian',
      '1101180.6': 'Ayla',
      '1101180.5': 'Ben',
      '1101180.4': 'Erin',
      '1101180.3': 'Zak Levy',
      '1101180.2': 'Charles',
      '808962.12': 'David'
    }
    if team['managers']['manager'].kind_of?(Array)
      names = team['managers']['manager'].map do |manager|
        manager.try(:[], 'nickname')
      end
      names -= ["Knotel"]
      puts "*"*80
      puts names.inspect, names.include?("--hidden--")
      puts "*"*80
      
      return mapping["#{league["league_id"]}.#{team["team_id"]}".to_sym] || '--hidden--' if names.include?("--hidden--")
      names.join(", ")
    else
      name = team['managers']['manager']['nickname']
      return mapping["#{league["league_id"]}.#{team["team_id"]}".to_sym] || '--hidden--' if name == "--hidden--"
      name
    end
  end
  
end
