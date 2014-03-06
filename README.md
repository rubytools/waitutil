## waitutil

[![Build Status](https://travis-ci.org/rubytools/waitutil.png?branch=master)](https://travis-ci.org/rubytools/waitutil)

`waitutil` provides tools for waiting for various conditions to occur, with a configurable
delay time, timeout, and logging.

GitHub: https://github.com/rubytools/waitutil

RubyGems: http://rubygems.org/gems/waitutil

Documentation: http://rubytools.github.io/waitutil/

### Examples

Wait methods take a block that returns `true` or `false`.

#### Waiting for conditions

Maximum wait time is one minute by default, and the delay time is one second.

```ruby
WaitUtil.wait_for_condition("my_event to happen") do
  check_if_my_event_happened
end
```

##### Customized wait time and delay time

```ruby
WaitUtil.wait_for_condition("my_event to happen", :timeout_sec => 30, :delay_sec => 0.5) do
  check_if_my_event_happened
end
```

##### Verbose logging

```ruby
WaitUtil.wait_for_condition('my event', :verbose => true) { sleep(1) }
```

Output:

```
I, [2014-02-16T00:34:31.511915 #15897]  INFO -- : Waiting for my event for up to 60 seconds
I, [2014-02-16T00:34:32.512223 #15897]  INFO -- : Success waiting for my event (1.000153273 seconds)
```

##### Returning additional information for the timeout log message

```ruby
attempt = 1
WaitUtil.wait_for_condition('my event', :verbose => true, :timeout_sec => 3, :delay_sec => 1) do
  sleep(1)
  attempt += 1
  [false, "attempt #{attempt}"]  # the second element goes into the log message
end
```

Output:

```
I, [2014-02-16T00:46:53.647936 #17252]  INFO -- : Waiting for my event for up to 3 seconds
WaitUtil::TimeoutError: Timed out waiting for my event (3 seconds elapsed): attempt 3
        from /home/mbautin/.rvm/gems/ruby-2.1.0/gems/waitutil-0.1.0/lib/waitutil.rb:39:in `wait_for_condition'
        from (irb):9
        from /home/mbautin/.rvm/rubies/ruby-2.1.0/bin/irb:11:in `<main>'
```

#### Waiting for service availability

Wait for a TCP server to be available using [wait_for_service](http://rubytools.github.io/waitutil/WaitUtil.html#wait_for_service-instance_method):

```ruby
WaitUtil.wait_for_service('my service', 'example.com', 80)
```

### License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
