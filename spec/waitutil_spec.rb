require 'waitutil'
require 'socket'

RSpec.configure do |configuration|
  configuration.include WaitUtil
end

describe WaitUtil do
  describe '.wait_for_condition' do
    it 'logs if the verbose option is specified' do
      iterations = []
      wait_for_condition('true', :verbose => true) {|iteration| iterations << iteration; true }
      expect(iterations).to eq([0])
    end

    it 'returns immediately if the condition is true' do
      iterations = []
      wait_for_condition('true') {|iteration| iterations << iteration; true }
      expect(iterations).to eq([0])
    end

    it 'should time out if the condition is always false' do
      iterations = []
      start_time = Time.now
      begin
        wait_for_condition('false', :timeout_sec => 0.1, :delay_sec => 0.01) do |iteration|
          iterations << iteration
          false
        end
        fail 'Expected an exception'
      rescue WaitUtil::TimeoutError => ex
        expect(ex.to_s).to match(/^Timed out waiting for false /)
      end
      elapsed_sec = Time.now - start_time
      expect(elapsed_sec).to be >= 0.1
      expect(iterations.length).to be >= 9
      expect(iterations.length).to be <= 11
      expect(iterations).to eq((0..iterations.length - 1).to_a)
    end

    it 'should handle additional messages from the block' do
      begin
        wait_for_condition('false', :timeout_sec => 0.01, :delay_sec => 0.05) do |iteration|
          [false, 'Some error']
        end
        fail 'Expected an exception'
      rescue WaitUtil::TimeoutError => ex
        expect(ex.to_s).to match(/^Timed out waiting for false (.*): Some error$/)
      end
    end

    it 'should treat the first element of returned tuple as condition status' do
      iterations = []
      wait_for_condition('some condition', :timeout_sec => 1, :delay_sec => 0) do |iteration|
        iterations << iteration
        [iteration >= 3, 'some message']
      end
      expect(iterations).to eq([0, 1, 2, 3])
    end

    it 'should evaluate the block return value as a boolean if it is not an array' do
      iterations = []
      wait_for_condition('some condition', :timeout_sec => 1, :delay_sec => 0) do |iteration|
        iterations << iteration
        iteration >= 3
      end
      expect(iterations).to eq([0, 1, 2, 3])
    end
  end

  describe '.wait_for_service' do
    BIND_IP = '127.0.0.1'

    it 'should succeed immediately when there is a TCP server listening' do
      # Find an unused port.
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp(BIND_IP, 0))
      port = socket.local_address.ip_port
      socket.close

      server_thread = Thread.new do
        server = TCPServer.new(port)
        loop do
          client = server.accept  # Wait for a client to connect
          client.puts "Hello !"
          client.close
          break
        end
      end

      wait_for_service('wait for my service', BIND_IP, port, :delay_sec => 0.1, :timeout_sec => 0.3)
    end

    it 'should fail when there is no TCP server listening' do
      port = nil
      # Find a port that no one is listening on.
      attempts = 0
      while attempts < 100
        port = 32768 + rand(61000 - 32768)
        begin
          TCPSocket.new(BIND_IP, port)
          port = nil
        rescue Errno::ECONNREFUSED
          break
        end
        attempts += 1
      end
      fail 'Could not find a port no one is listening on' unless port

      expect {
        wait_for_service(
          'wait for non-existent service', BIND_IP, port, :delay_sec => 0.1, :timeout_sec => 0.3
        )
      }.to raise_error(WaitUtil::TimeoutError)
    end

  end
end
