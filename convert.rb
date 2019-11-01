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

# return noballs
def noballs_for(delivery)
  return 0 unless delivery.key?('extras')
  return 0 unless delivery['extras'].key?('noballs')
  delivery['extras']['noballs']
end

def wides_for(delivery)
  return 0 unless delivery.key?('extras')
  return 0 unless delivery['extras'].key?('wides')
  delivery['extras']['wides']
end

def byes_for(delivery)
  return 0 unless delivery.key?('extras')
  return 0 unless delivery['extras'].key?('byes')
  delivery['extras']['byes']
end

def legbyes_for(delivery)
  return 0 unless delivery.key?('extras')
  return 0 unless delivery['extras'].key?('legbyes')
  delivery['extras']['legbyes']
end

# Write the info csv file
# I might change this to output a fixed set of columns but doing this for now

CSV.open(info_outfile, "wb") do |csv|
  csv << [
    'match_id',
    'format',
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
    yaml['info']['match_type'],
    yaml['info']['teams'][0],
    yaml['info']['teams'][1],
    yaml['info']['gender'],
    yaml['info']['dates'][0],
    yaml['info']['dates'][-1],            
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
    if yaml['info']['outcome'].key?('winner')
      'won'
    else
      # obviously needs to be updated to handle other result types 
      'drawn'
    end,
    '',
    if yaml['info']['outcome'].key?('winner')
      yaml['info']['outcome']['winner']
    else
      ''
    end,
    if yaml['info']['outcome'].key?('by')
      if yaml['info']['outcome']['by'].key?('runs')
        yaml['info']['outcome']['by']['runs']
      elsif yaml['info']['outcome']['by'].key?('wickets')
        yaml['info']['outcome']['by']['wickets']
      end
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
    'runs',
    'batter_runs',
    'noballs',
    'wides',
    'byes',
    'legbyes',
    'bowler_runs',
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

          runs = delivery['runs']['total']
          batter_runs = delivery['runs']['batsman']
          noballs = noballs_for(delivery)
          wides = wides_for(delivery)
          byes = byes_for(delivery)
          legbyes = legbyes_for(delivery)
          # runs attributal to bowler excludes byes and legbyes
          bowler_runs = runs - byes - legbyes

          csv << [
            match,
            inning_no + 1,
            ball_no,
            inning_data['team'],
            delivery['batsman'],
            delivery['non_striker'],
            delivery['bowler'],
            runs,
            batter_runs,
            noballs,
            wides,
            byes,
            legbyes,
            bowler_runs,
            dismissal_methods_for(delivery),
            dismissed_players_for(delivery)
          ]
        end
      end
    end
  end
end