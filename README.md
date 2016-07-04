# casteml

Provide a comprehensive utility for CASTEML

# Dependency

## [medusa_rest_client](https://github.com/misasa/medusa_rest_client "follow instruction")

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'casteml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install casteml

# Commands

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

# Usage

See online document with option `--help`.

# Developer's guide

1. Run test

```
$ cd ~/devel-godigo/gems/casteml
$ bundle exec rspec spec/casteml/command_manager_spec.rb
$ bundle exec rspec spec/casteml/commands/convert_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/spots_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/join_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/split_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/upload_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/download_command_spec.rb --tag show_help:true
$ bundle exec rspec spec/casteml/commands/plot_command_spec.rb --tag show_help:true
```

2. Push to the Git server

3. Access to Jenkins server http://devel.misasa.okayama-u.ac.jp/jenkins/job/Casteml/ and run a job.  This is scheduled and if you are not in hurry, skip further steps.

4. Uninstall and install local gem module by

```
$ sudo gem uninstall casteml
$ sudo gem install casteml
```
