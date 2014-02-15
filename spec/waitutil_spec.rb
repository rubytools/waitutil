require 'waitutil'

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
      rescue RuntimeError => ex
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
      rescue RuntimeError => ex
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
end
