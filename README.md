## waitutil

`waitutil` provides tools to wait for various conditions to occur, with a configurable
delay time, timeout, and logging.

### Examples

```ruby
WaitUtil.wait_for_condition("my_event to happen") do
  check_if_my_event_happened
end
```

### License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
