module QuickTest
class Result
  attr_accessor :fail_stack_hash
  attr_accessor :error_stack_hash
  attr_accessor :seconds_per_test
  attr_accessor :faults

  def initialize quick_test_runner
    self.faults = quick_test_runner.faults
    self.seconds_per_test = quick_test_runner.seconds_per_test
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

  def output_metrics
    tests_longer_than_threshold = self.seconds_per_test.collect {|test,time| [test, time] if time > 0.5}.compact
    sorted_tests = tests_longer_than_threshold.sort {|x, y| y[1] <=> x[1]}

    puts "Tests that took longer than threshold (#{sorted_tests.length} occurences): "
    puts "Time (s)".rjust(20).color(:blue).bright + "  " + "Test File".ljust(20).color(:blue).bright + "  " + "Test Name".ljust(20).color(:blue).bright

    sorted_tests.each do |t|
      time = "#{t[1]}"
      test_name = t[0][/(.*)\(.*\)$/,1]
      test_file = t[0].gsub(test_name, "").delete('()')
      puts time.rjust(20).color(:green) + "  " + test_file.ljust(20).color(:green) + "  " + test_name.ljust(20).color(:green).bright
    end
  end
end
end
