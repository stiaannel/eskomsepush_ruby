# eskomsepush_ruby API Wrapper

![Tests](https://github.com/stiaannel/eskomsepush_ruby/actions/workflows/ci-cd.yml/badge.svg)


A Ruby wrapper for the EskomSePush API V2. This gem provides a simple and intuitive interface to interact with the EskomSePush services.

## Important Notice

Users of this library are bound by the terms in the EskomSePush's license agreement. Please review their [terms of service](https://sepush.co.za/license-agreement) before using this gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eskom_se_push_ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install eskom_se_push_ruby
```

## Usage

### Configuration

```ruby
esp = EskomSePush.client('your-api-key')
```

### Examples

```ruby
# Example of checking your quota
quota = esp.quota.allowance
puts quota

area_schedule = esp.area_information('area_id')
puts area_schedule
```

### Error Handling

This gem will raise specific errors for different API responses:

- `YourGemName::BadRequestError` - HTTP 400
- `YourGemName::AuthenticationError` - HTTP 403
- `YourGemName::NotFoundError` - HTTP 404
- `YourGemName::RequestTimeoutError` - HTTP 408
- `YourGemName::RateLimitError` - HTTP 429
- `YourGemName::ServerError` - HTTP 500-599
- `YourGemName::UnexpectedError` - Other errors

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stiaannel/eskomsepush_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of Conduct

Everyone interacting in this project's codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
