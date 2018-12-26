# Yabeda Datadog adapter

[Yabeda](https://github.com/yabeda-rb/yabeda) adapter for easy exporting collected custom metrics from your application to the Datadog API.


## Installation

This adapter sends metrics to [Datadog API](https://docs.datadoghq.com/api/?lang=ruby) and requires you to have a Datadog account with API key and application key. You can obtain your Datadog API keys in [Datadog dashboard](https://app.datadoghq.com/account/settings#api). For more information refer to [API documentation](https://docs.datadoghq.com/api/?lang=ruby#authentication).

Add line to your application's Gemfile:

```ruby
gem 'yabeda-datadog'
```

And then execute:

    $ bundle

Have an instance of Datadog agent and dogstats-d running. For other installation options of datadog agent please refer to [Datadog agent documentation](https://docs.datadoghq.com/agent/).

## Usage

Configure Yabeda metrics. Refer to [Yabeda documentation](https://github.com/yabeda-rb/yabeda) for instruction how to configure and use Yabeda metrics.

Please note when configuring Yabeda you have to use Datadog units. Refer to [Datadog unit for metrics documentation](https://docs.datadoghq.com/developers/metrics/#units).
If a unit of a metric is not supported by Datadog, this unit will not be automatically updated. But you always have ability to update it manyaly in Datadog metrics dashboard or by calling API by yourself.

Refer to [Datadog metrics documentation](https://docs.datadoghq.com/graphing/metrics/) for working with your metrics in Datadog dashboard.

You may specify `DATADOG_AGENT_HOST` and/or `DATADOG_AGENT_PORT` environment variables if your datadog agent is runned not in same host as an app/code that you collection metrics.

HOST?

### Limitations

On first run of your application no metrics metadata will be uptaded. This is happens because metrics have not yet been collected, thus not been created, and there are nothing to update.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

In can run a dogstats-d instance in a docker container with following command:

    $ bin/dev

Beware that the agent will collect metrics (a lot) from docker itself and all launched docker containers.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shvetsovdm/yabeda-datadog.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
