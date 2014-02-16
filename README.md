## waitutil

[![Build Status](https://travis-ci.org/rubytools/waitutil.png?branch=master)](https://travis-ci.org/rubytools/waitutil)

`waitutil` provides tools for waiting for various conditions to occur, with a configurable
delay time, timeout, and logging.

This gem on RubyGems: http://rubygems.org/gems/waitutil.

Full documentation available at http://rubytools.github.io/waitutil/.

### Examples

Wait methods take a block that returns `true` or `false`

#### Waiting for conditions

Maximum wait time is one minute by default, and the delay time is one second.

```ruby
WaitUtil.wait_for_condition("my_event to happen") do
  check_if_my_event_happened
end
```

Customized wait time and delay time:

```ruby
WaitUtil.wait_for_condition("my_event to happen", :timeout_sec => 30, :delay_sec => 0.5) do
  check_if_my_event_happened
end
```

#### Waiting for service availability

Wait for a TCP server to be available:

```ruby
WaitUtil.wait_for_service('example.com', 8080)
```

### License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
