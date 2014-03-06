require 'logger'
require 'socket'

module WaitUtil

  extend self

  class TimeoutError < StandardError
  end

  DEFAULT_TIMEOUT_SEC = 60
  DEFAULT_DELAY_SEC = 1

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::INFO

  def self.logger
    @@logger
  end

  # Wait until the condition computed by the given block is met. The supplied block may return a
  # boolean or an array of two elements: whether the condition has been met and an additional
  # message to display in case of timeout.
  def wait_for_condition(description, options = {}, &block)
    delay_sec = options.delete(:delay_sec) || DEFAULT_DELAY_SEC
    timeout_sec = options.delete(:timeout_sec) || DEFAULT_TIMEOUT_SEC
    verbose = options.delete(:verbose)
    unless options.empty?
      raise "Invalid options: #{options}"
    end

    if verbose
      @@logger.info("Waiting for #{description} for up to #{timeout_sec} seconds")
    end

    start_time = Time.now
    stop_time = start_time + timeout_sec
    iteration = 0

    # Time when we started to evaluate the condition.
    condition_eval_start_time = start_time

    until is_condition_met(condition_result = yield(iteration))
      current_time = Time.now
      if current_time - start_time >= timeout_sec
        raise TimeoutError.new(
          "Timed out waiting for #{description} (#{timeout_sec} seconds elapsed)" +
          get_additional_message(condition_result)
        )
      end

      # The condition evaluation function might have taken some time, so we subtract that time
      # from the time we have to wait.
      sleep_time_sec = condition_eval_start_time + delay_sec - current_time
      sleep(sleep_time_sec) if sleep_time_sec > 0

      iteration += 1
      condition_eval_start_time = Time.now  # we will evaluate the condition again immediately
    end

    if verbose
      @@logger.info("Success waiting for #{description} (#{Time.now - start_time} seconds)")
    end
    true
  end

  # Wait until a TCP service is available at the given host/port.
  def wait_for_service(description, host, port, options = {})
    wait_for_condition("#{description} to become available on #{host}, port #{port}",
                       options) do
      begin
        is_tcp_port_open(host, port, options[:delay_sec] || DEFAULT_DELAY_SEC)
      rescue SocketError
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

  # Check if the given TCP port is open on the given port with a timeout.
  def is_tcp_port_open(host, port, timeout_sec = nil)
    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sockaddr = Socket.sockaddr_in(port, host)
    result = begin
      socket.connect_nonblock(sockaddr)
      true
    rescue Errno::EINPROGRESS
      reader, writer, error = IO.select([socket], [socket], [socket], timeout_sec)
      if writer.nil? || writer.empty?
        false
      else
        # Sometimes we have to write some data to the socket to find out whether we are really
        # connected.
        begin
          writer[0].write_nonblock("\x0")
          true
        rescue Errno::ECONNREFUSED
          false
        end
      end
    end
    socket.close
    result
  end

  extend WaitUtil
end
