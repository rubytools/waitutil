## waitutil

[![Build Status](https://travis-ci.org/mbautin/waitutil.png?branch=master)](https://travis-ci.org/mbautin/waitutil)

`waitutil` provides tools for waiting for various conditions to occur, with a configurable
delay time, timeout, and logging.

### Examples

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

### License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
