module QuickTest
  class Result
    attr_accessor :fail_stack_hash
    attr_accessor :error_stack_hash
    attr_accessor :seconds_per_test
    attr_accessor :faults

    def initialize test_runner
      self.faults = test_runner.faults
      self.seconds_per_test = test_runner.seconds_per_test
    end

    def passed?
      self.failure_test_names.empty? && self.error_test_names.empty?
    end

    def fault_test_names
      names = []
      self.faults.collect do |f|
        names << f.test_name[/(.*)\(.*\)$/,1]
      end
      names
    end

    def output_metrics configuration
      tests_longer_than_threshold = self.seconds_per_test.collect {|test,time| [test, time] if time > configuration.threshold_slow_warning}.compact
      sorted_tests = tests_longer_than_threshold.sort {|x, y| y[1] <=> x[1]}

      tr = TableRenderer.new \
        :title => "Tests that took longer than the threshold of #{configuration.threshold_slow_warning} seconds (#{sorted_tests.length} occurences):",
        :columns => [
          ["Time (s)", 8, TableRenderer::ALIGN_RIGHT],
          ["Test Class", 30, TableRenderer::ALIGN_LEFT],
          ["Test Name", 50, TableRenderer::ALIGN_LEFT]
        ],
        :no_data_output => "No tests took longer than the threshold."

      data = []
      sorted_tests.each do |t|
        time = t[1]
        test_name = t[0][/(.*)\(.*\)$/,1]
        test_class = t[0].gsub(test_name, "").delete('()')
        data << [time, test_class, test_name]
      end
      tr.render_with_data data

    end
  end
end
