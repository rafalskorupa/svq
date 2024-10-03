# Fcmex

**TODO: Add description**

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



```elixir
def deps do
  [
    {:fcmex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/fcmex>.

