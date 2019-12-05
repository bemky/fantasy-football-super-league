class ApplicationController < ActionController::Base

  before_action :set_root_url
  before_action :set_access_token
  
  def index
    if Date.today >= Date.parse('2019-11-26')
      redirect_to :bracket
    else
      redirect_to :standings
    end
  end
  
  def bracket
    standings
    
    @standings = @ones + @standings
    @standings.each_with_index do |team, index|
      team[:seed] = index + 1
    end
    
    @octo_finals = [
      [
        {
          team: @standings[7],
          points: @standings[7][:weekly_points][12],
          projected_points: @standings[7][:weekly_projected_points][12]
        },{
          team: @standings[8],
          points: @standings[8][:weekly_points][12],
          projected_points: @standings[8][:weekly_projected_points][12]
        },
      ],[
        {
          team: @standings[4],
          points: @standings[4][:weekly_points][12],
          projected_points: @standings[4][:weekly_projected_points][12]
        },{
          team: @standings[11],
          points: @standings[11][:weekly_points][12],
          projected_points: @standings[11][:weekly_projected_points][12]
        },
      ],[
        {
          team: @standings[5],
          points: @standings[5][:weekly_points][12],
          projected_points: @standings[5][:weekly_projected_points][12]
        },{
          team: @standings[10],
          points: @standings[10][:weekly_points][12],
          projected_points: @standings[10][:weekly_projected_points][12]
        },
      ],[
        {
          team: @standings[6],
          points: @standings[6][:weekly_points][12],
          projected_points: @standings[6][:weekly_projected_points][12]
        },{
          team: @standings[9],
          points: @standings[9][:weekly_points][12],
          projected_points: @standings[9][:weekly_projected_points][12]
        },
      ]
    ]
    
    @quarter_finals = [
      [
        {
          team: @standings[0],
          points: @standings[0][:weekly_points][13],
          projected_points: @standings[0][:weekly_projected_points][13]
        }, @week_number > 13 ? {
          team: @octo_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @octo_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][13],
          projected_points: @octo_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][13],
        } : nil,
      ],[
        {
          team: @standings[3],
          points: @standings[3][:weekly_points][13],
          projected_points: @standings[1][:weekly_projected_points][13]
        }, @week_number > 13 ? {
          team: @octo_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @octo_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][13],
          projected_points: @octo_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][13],
        } : nil,
      ],[
        {
          team: @standings[2],
          points: @standings[2][:weekly_points][13],
          projected_points: @standings[2][:weekly_projected_points][13]
        }, @week_number > 13 ? {
          team: @octo_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @octo_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][13],
          projected_points: @octo_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][13],
        } : nil,
      ],[
        {
          team: @standings[1],
          points: @standings[1][:weekly_points][13],
          projected_points: @standings[3][:weekly_projected_points][13]
        }, @week_number > 13 ? {
          team: @octo_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @octo_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][13],
          projected_points: @octo_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][13],
        } : nil,
      ]
    ]
    
    @semi_finals = [
      [
        @week_number > 14 ? {
          team: @quarter_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @quarter_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][14],
          projected_points: @quarter_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][14],
        } : nil, @week_number > 14 ? {
          team: @quarter_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @quarter_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][14],
          projected_points: @quarter_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][14],
        } : nil,
      ], [
        @week_number > 14 ? {
          team: @quarter_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @quarter_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][14],
          projected_points: @quarter_finals[2].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][14],
        } : nil, @week_number > 14 ? {
          team: @quarter_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @quarter_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][14],
          projected_points: @quarter_finals[3].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][14],
        } : nil,
      ]
    ]
    
    @finals = [
      [
        @week_number > 15 ? {
          team: @semi_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @semi_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][15],
          projected_points: @semi_finals[0].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][15],
        } : nil, @week_number > 15 ? {
          team: @semi_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team],
          points: @semi_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][15],
          projected_points: @semi_finals[1].max{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][15],
        } : nil
      ], [
        @week_number > 15 ? {
          team: @semi_finals[0].min{|a, b| a[:points] <=> b[:points]}[:team],
          points: @semi_finals[0].min{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][15],
          projected_points: @semi_finals[0].min{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][15],
        } : nil, @week_number > 15 ? {
          team: @semi_finals[1].min{|a, b| a[:points] <=> b[:points]}[:team],
          points: @semi_finals[1].min{|a, b| a[:points] <=> b[:points]}[:team][:weekly_points][15],
          projected_points: @semi_finals[1].min{|a, b| a[:points] <=> b[:points]}[:team][:weekly_projected_points][15],
        } : nil
      ]
    ]
  end
  
  def standings
    response = Yahoo.get("/leagues;league_keys=#{league_ids}/teams/matchups", session[:access_token]);
    @data = Hash.from_xml(response)
    
    week_data = []
    week_data[13] = Hash.from_xml(Yahoo.get("/leagues;league_keys=#{league_ids}/teams/stats;type=week;week=14", session[:access_token]))
    week_data[14] = Hash.from_xml(Yahoo.get("/leagues;league_keys=#{league_ids}/teams/stats;type=week;week=15", session[:access_token]))
    week_data[15] = Hash.from_xml(Yahoo.get("/leagues;league_keys=#{league_ids}/teams/stats;type=week;week=16", session[:access_token]))
    
    @week_number = 0;
    @ones = [];
    @standings = @data['fantasy_content']['leagues']['league'].map do |league|
      @week_number = league['current_week'].to_i
      @week_number = 17 if league['is_finished'] == "1"

      teams = league['teams']["team"].map do |team|
        points = team['matchups']['matchup'].map do |x|
          points = x['teams']['team'].find{|x| x['team_id'] == team["team_id"]}['team_points']['total'].to_f
          week = x['week'].to_i
          week >= @week_number || week > 12 ? 0 : points
        end
        points = points.sum

        current_matchup = team['matchups']['matchup'].find{|x| x['week'].to_i == @week_number}
        week_points = current_matchup['teams']['team'].find{|x| x['team_id'] == team['team_id']}['team_points']['total'].to_f if @week_number < 13
        weekly_points = []
        weekly_projected_points = []
        team['matchups']['matchup'].each do |x|
          weekly_points[x['week'].to_i - 1] = x['teams']['team'].find{ |x| x['team_id'] == team["team_id"] }['team_points']['total'].to_f
        end
      
        weekly_projected_points = team['matchups']['matchup'].map do |x|
          weekly_projected_points[x['week'].to_i - 1] = x['teams']['team'].find{ |x| x['team_id'] == team["team_id"] }['team_projected_points']['total'].to_f
        end
        
        [weekly_points[13], weekly_points[14], weekly_points[15]].each_with_index do |v, i|
          next if v
          index = i + 13
          league_data = week_data[index]['fantasy_content']['leagues']['league'].find{|x| x['league_id'] == league['league_id']}
          team_data = league_data['teams']['team'].find{|x| x['team_id'] == team['team_id']}
          weekly_points[index] = team_data['team_points']['total'].to_f
          weekly_projected_points[index] = team_data['team_projected_points']['total'].to_f
        end
        
        {
          name: team['name'],
          logo: team['team_logos']['team_logo']['url'],
          id: team['team_id'],
          league_id: league['league_id'],
          league: league['name'],
          points: points,
          week_points: week_points,
          manager: manager(team, league),
          weekly_points: weekly_points,
          weekly_projected_points: weekly_projected_points
        }
      end

      one_seed = teams.sort_by{|x| [x[:points], x[:week_points]]}.reverse.first
      @ones << one_seed
      teams.reject!{|x| x == one_seed}

      teams
    end.flatten.sort_by{|x| [x[:points], x[:week_points]]}.reverse
    @ones = @ones.sort_by{|x| [x[:points], x[:week_points]]}.reverse
    
  end
  
  def debug
    # response = Yahoo.get("/teams;team_keys=390.l.1101180.t.1/matchups;weeks=11,16", session[:access_token]);
    # response = Yahoo.get("/leagues;league_keys=#{league_ids.map{|x| "390.l.#{x}"}.join(",")}/teams/matchups", session[:access_token]);
    # @data = Hash.from_xml(response)
    
    response = Yahoo.get("/leagues;league_keys=#{league_ids}/teams/stats;type=week;week=13", session[:access_token]);
    @data = Hash.from_xml(response)

    render json: @data
  end
  
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
  
  def league_ids
    %w(1101180 829718 1057144 808962).map{|x| "390.l.#{x}"}.join(",")
    # %w(1031939 144803).map{|x| "380.l.#{x}"}.join(",")
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
      
      return mapping["#{league["league_id"]}.#{team["team_id"]}".to_sym] || '--hidden--' if names.include?("--hidden--")
      names.join(", ")
    else
      name = team['managers']['manager']['nickname']
      return mapping["#{league["league_id"]}.#{team["team_id"]}".to_sym] || '--hidden--' if name == "--hidden--"
      name
    end
  end
  
  def get_bracket(seeds)
    
  end
  
end
