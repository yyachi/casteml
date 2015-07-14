# Casteml

Provide a comprehensive utility for CASTEML

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'casteml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install casteml

## Commands

Commands are summarized as:

| command          | description                                   | note                       |
|------------------|-----------------------------------------------|----------------------------|
| casteml convert  | convert between CSV, TSV, ORG, ISORG, PML     |                            |
| casteml spots    | create LaTeX spot from PML                    | isocircle option available |
| casteml join     | create a multi-pmlfile from single pmlfiles   |                            |
| casteml split    | create single pmlfiles from a multi-pmlfile   |                            |
| casteml upload   | upload pmlfile to Medusa                      |                            |
| casteml download | download pmlfile from Medusa                  |                            |
| casteml plot     | make a plot using pmlfile                     |                            |

## Usage

See online document with option `--help`.

## Show the help message
    $ cd ~/godigo-devel/gems/casteml
    $ bundle exec rspec spec/casteml/commands/convert_command_spec.rb --tag show_help:true

## Contributing

1. Fork it ( https://github.com/[my-github-username]/casteml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request