# Fcmex

## Installation

Erlang/Elixir(`.tool-versions` for asdf provided)

* Erlang 26.1.2
* Elixir 1.15.7-otp-26

```
mix compile
```

## Usage

`mix convert.from_svq <input> <output>`

Can take up to two arguments - they are not validated properly
First argument is path to input file
Second argument is path to output file

If only one argument is provided it's going to be used as input file and result will be printed to IO

If none arguments are provided, input_file is defaulted to input.txt

### Examples

#### From file to IO

`mix convert.from_svq input.txt`

#### From file to file

`mix convert.from_svq input.txt output.txt`
Converts input.txt SVQ to output.txt (commited to git, can be verified)

#### Invalid input

`mix convert.from_svq invalid.txt`
Return error results


## Notes

No external dependencies, the whole `fcmex` directory could be copy pasted into existing project and adjusted. 

Added a little bit more comments I would do normally :)

I purposfully ignored trips that doesn't end in origin location - I think that wouldn't be difficult to implement, but the decision how it would be resolved in domain it's definitely something I wouldn't take on my own.

Sorting & aggregating segments to Trips is contained in Fcmex.Trips

Tests are difficult to read, but they've got good coverage of cases I thought of - I would have to think more about how to simplify them and look for corner cases more.

Skipped:
* validations:
  * IATA (as long as it's single word without blank spaces it's going to work) - probably would be not only validated whether it's 3-character string, but also against existing list of IATAs
  * Dates - unless validations by raising error if something goes wrong count (imho - definitely no!). I would think about parsing Dates to DateTime at the level of parsing SVQ and building struct 