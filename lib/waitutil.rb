require 'logger'

module WaitUtil
  extend self

  DEFAULT_TIMEOUT_SEC = 60
  DEFAULT_DELAY_SEC = 1

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::INFO

  # Wait until the condition computed by the given block is met. The supplied block may return a
  # boolean or an array of two elements: whether the condition has been met and an additional
  # message to display in case of timeout.
  def wait_for_condition(description, options = {}, &block)
    sleep_sec = options.delete(:sleep_sec) || DEFAULT_DELAY_SEC
    timeout_sec = options.delete(:timeout_sec) || DEFAULT_TIMEOUT_SEC
    verbose = options.delete(:verbose)
    unless options.empty?
      raise "Invalid options: #{options}"
    end

    if verbose
      @@logger.info("Waiting for #{description} for up to #{timeout_sec} seconds")
    end

    start_time = Time.now
    iteration = 0
    until is_condition_met(condition_result = yield(iteration))
      if Time.now - start_time >= timeout_sec
        raise "Timed out waiting for #{description} (#{timeout_sec} seconds elapsed)" +
              get_additional_message(condition_result)
      end
      sleep(sleep_sec)
      iteration += 1
    end
    if verbose
      @@logger.info("Success waiting for #{description} (#{Time.now - start_time} seconds)")
    end
    true
  end

  # Wait until a service is available at the given host/port.
  def wait_for_service(description, host, port, options = {})
    wait_for_condition("#{description} port #{port} to become available on #{host}",
                       options) do
      begin
        s = TCPSocket.new(host, port)
        s.close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  end

  private

  def is_condition_met(condition_result)
    condition_result.kind_of?(Array) ? condition_result[0] : condition_result
  end

  def get_additional_message(condition_result)
    condition_result.kind_of?(Array) ? ': ' + condition_result[1] : ''
  end

  extend WaitUtil
end
