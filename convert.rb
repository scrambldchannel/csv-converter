#!/usr/bin/env ruby

require 'csv'
require 'yaml'

VERSION = '1.2.0'

# Which file are we converting?
file = ARGV[0] || exit
match = file.split('.')[0]

# Assuming the input was a valid yaml file, build file names for the output files
info_outfile = match + '_info.csv'
deliveries_outfile = match + '_deliveries.csv'

# Load the yaml file.
yaml = YAML.load_file(file)

# helper function definitions

# returns the wicket array if relevant for the given delivery
def dismissals_for(delivery)
  delivery['wicket'].is_a?(Array) ? delivery['wicket'] : [delivery['wicket']]
end

# if a wicket happened, return the kind of dismissal(s)
def dismissal_methods_for(delivery)
  return '' unless delivery.key?('wicket')
  dismissals_for(delivery).map { |dismissal| dismissal['kind'] }.join(', ')
end

# if a wicket happened, return the dismissed batter(s)
def dismissed_players_for(delivery)
  return '' unless delivery.key?('wicket')
  dismissals_for(delivery).map { |dismissal| dismissal['player_out'] }.join(', ')
end

# Write the info csv file
# I might change this to output a fixed set of columns but doing this for now

CSV.open(info_outfile, "wb") do |csv|
  csv << [
    'match_id',
    'csv_version',
    'yaml_version',
    'home_team',
    'away_team',
    'gender',
    'start_date',
    'end_date',
    'competition',
    'venue',
    'city',
    'neutral_venue',
    'toss_winner',
    'toss_decision',
    'player_of_match',
    'umpire 1',
    'umpire 2',
    'result',
    'margin_type',
   # 'method',
    'winner',
    'margin'
  ]

  csv << [
    match,
    VERSION,
    yaml['meta']['version'],
    yaml['info']['teams'][0],
    yaml['info']['teams'][1],
    yaml['info']['gender'],
    yaml['info']['dates'][0],
    # this is wrong, will fix later but need to work out how to get last item in array in ruby
    yaml['info']['dates'][4],            
    if yaml['info'].key?('competition')
      yaml['info']['competition']
    else
      ''
    end,
    yaml['info']['venue'],
    yaml['info']['city'],
    if yaml['info'].has_key?('neutral_venue')
      'True'
    else
      'False'
    end,
    yaml['info']['toss']['winner'],
    yaml['info']['toss']['decision'],
    if yaml['info'].key?('player_of_match')
      # can we have multiple pom?
      yaml['info']['player_of_match']
    end,
    if yaml['info'].key?('umpires')
      yaml['info']['umpires'][0]
    else
      ''
    end,
    if yaml['info'].key?('umpires')
      yaml['info']['umpires'][1]
    else
      ''
    end,
    if yaml['info']['outcome'].key?('result')
      yaml['info']['outcome']['result']
    else
      ''
    end,
    if yaml['info']['outcome'].key?('winner')
      yaml['info']['outcome']['winner']
    else
      ''
    end,
    if yaml['info']['outcome'].key?('by')
      yaml['info']['outcome']['by']
    else
      ''
    end

    ]


end

#  Write the deliveries csv file
CSV.open(deliveries_outfile, "wb") do |csv|

  # write header row
  csv << [
    'match_id',
    'innings',
    'ball',
    'batting_team',
    'batter',
    'non_striker',
    'bowler',
    'batter_runs',
    'extra_runs',
    'how_out',
    'batter_out'
  ]


  # Now deal with the innings.
  yaml['innings'].each_with_index do |inning, inning_no|
  
    inning.each_pair do |inning_name, inning_data|
  
      if inning_data.key?('penalty_runs')
        %w(pre post).each do |type|
          next unless inning_data['penalty_runs'].key?(type)
          csv << [
            'penalty_runs',
            inning_no + 1, type,
            inning_data['penalty_runs'][type]
          ]
        end
      end

      inning_data['deliveries'].each do |delivery_data|
        delivery_data.each_pair do |ball_no, delivery|
          csv << [
            match,
            inning_no + 1,
            ball_no,
            inning_data['team'],
            delivery['batsman'],
            delivery['non_striker'],
            delivery['bowler'],
            delivery['runs']['batsman'],
            delivery['runs']['extras'],
            dismissal_methods_for(delivery),
            dismissed_players_for(delivery)
          ]
        end
      end
    end
  end
end