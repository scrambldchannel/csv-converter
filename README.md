# csv-converter

A ruby script to convert [version 0.9](https://cricsheet.org/format/) [Cricsheet YAML data files](https://cricsheet.org/downloads/) into CSV. 

The script is a fork from the [original script](https://github.com/cricsheet/csv-converter) to fulfill slightly different requuirements, notably:

* rather than outputting to stdout this version writes two separate csv files:
  * <match_id>_info.csv containing the match meta data
    * the original info fields are transposed to columns
  * <match_id>_deliveries.csv containing each ball
    * the columns have been tweaked a little

## Usage

`convert.rb` is a ruby script. It takes the path to a single match file (in version 0.9 YAML format), and writes two csv files in the working directory

### Examples

Convert a single YAML file from cricsheet, and create two csv files:

```bash
$ ./convert.rb 1152846.yaml
$ ls 1152846.*
1152846_deliveries.csv  1152846_info.csv  1152846.yaml
```
