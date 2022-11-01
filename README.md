# TimezoneValue

Rails value to Work with use Timezones and store in activeRecord

## Installation

Add to your Gemfile:

```ruby
gem 'timezone_value', github: "NEXL-LTS/timezone_value-ruby", branch: "main"
gem "rails_values", github: "NEXL-LTS/rails_values", branch: "main"
```

## Usage

```ruby
class Person < ApplicationRecord
  attribute :timezone, :rv_timezone_value
end

person = Person.new
person.timezone = "UTC"
puts person.timezone.to_s # => "UTC"
puts person.timezone.name # => "(GMT+00:00) UTC"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NEXL-LTS/timezone_value-ruby.
