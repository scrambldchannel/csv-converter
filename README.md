# csv-converter

A ruby script to convert [version 0.9](https://cricsheet.org/format/) [Cricsheet YAML data files](https://cricsheet.org/downloads/) into CSV. 

The script is a fork from the [original script](https://github.com/cricsheet/csv-converter) to fulfill slightly different requuirements, notably:

* rather than outputting to stdout this version writes two separate csv files:
  * <match_id>_info.csv containing the match meta data
    * the original info fields are transposed to columns
  * <match_id>_deliveries.csv containing each ball
    * the columns have been tweaked a little

Thanks go to Stephen Rushe (https://github.com/srushe
) for the original script and, more importantly, the crichseet project 

## Usage

`convert.rb` is a ruby script. It takes the path to a single match file (in version 0.9 YAML format), and writes two csv files in the working directory

### Examples

Convert a single YAML file from cricsheet, and create two csv files:

```bash
$ ./convert.rb 1152846.yaml
$ ls 1152846.*
1152846_deliveries.csv  1152846_info.csv  1152846.yaml
```

The info file looks like this:

```bash
$ head 1152846_info.csv
match_id,format,home_team,away_team,gender,start_date,end_date,competition,venue,city,neutral_venue,toss_winner,toss_decision,player_of_match,umpire 1,umpire 2,result,margin_type,winner,margin
1152846,Test,England,Australia,male,2019-08-01,2019-08-05,"",Edgbaston,Birmingham,False,Australia,bat,SPD Smith,Aleem Dar,JS Wilson,won,"",Australia,251
```
The deliveries file looks like this:

```bash
$ head -n 5 1152846_deliveries.csv
match_id,innings,ball,batting_team,batter,non_striker,bowler,runs,batter_runs,4s,6s,noballs,wides,byes,legbyes,bowler_runs,how_out,batter_out
1152846,1,0.1,Australia,CT Bancroft,DA Warner,JM Anderson,0,0,0,0,0,0,0,0,0,"",""
1152846,1,0.2,Australia,CT Bancroft,DA Warner,JM Anderson,0,0,0,0,0,0,0,0,0,"",""
1152846,1,0.3,Australia,CT Bancroft,DA Warner,JM Anderson,0,0,0,0,0,0,0,0,0,"",""
1152846,1,0.4,Australia,CT Bancroft,DA Warner,JM Anderson,0,0,0,0,0,0,0,0,0,"",""
```

## Known issues

This was really something I adapted quickly to process a specific list of matches I was interested in and isn't very robust nor has it been tested on anything but a few test matches.

* Doesn't capture penalty runs
* Doesn't handle more than one Player or Match
* Doesn't process result type very intelligently and won't capture ties for example
* Should probably encase string values in quotes but doesn't

