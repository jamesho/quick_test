module QuickTest
  class QuickTest
    attr_accessor :experiments
    attr_accessor :current_experiment

    def initialize args={}
      self.experiments = []
    end
=begin
  def run_func test_path
    test_file = "test/functional/#{test_path}_test.rb"
    load test_file
    test_class = begin
     "#{test_path.split('/').last.camelize}Test".constantize
    rescue NameError
      "#{test_path.camelize}Test".constantize
    end

    test_suite = Test::Unit::TestSuite.new(test_class.to_s)
    test_names = test_class.suite.tests.collect do |t|
        t.method_name
    end.compact

    test_names.each do |tn|
      test_suite << test_class.new(tn)
    end

     begin
      runner = QuickTestRunner.new(test_suite)
      runner.start

      result = Result.new(runner)
      result.output_metrics

      test_suite.tests.each {|t| puts "    #{t.method_name}"}

    ensure
    end
    nil
  end
=end
    def run test_path_or_experiment_number=nil, keyword=nil
      if test_path_or_experiment_number.is_a? Integer
        # TODO: handle bad numbers
        self.current_experiment = self.experiments[test_path_or_experiment_number]
      elsif test_path_or_experiment_number
        self.current_experiment = Experiment.new test_path_or_experiment_number, keyword
        self.experiments << self.current_experiment
      end

      self.current_experiment.run
      nil
    end

    def run_bad
      self.current_experiment.run_faults
      nil
    end

    def freeze
      self.current_experiment.freeze_result
      nil
    end

    def unfreeze
      self.current_experiment.unfreeze_result
      nil
    end

    def metrics number=nil
      self.current_experiment.output_metrics number
      nil
    end

    def list
      if self.experiments.size == 0
        puts "No experiments have been run."
        return
      end

      header = "###" + " " + "Test".ljust(20) + " " + "Keyword".ljust(10) + " " + "Results"
      puts header.color(:blue).bright
      self.experiments.each_with_index do |exp, n|
        puts "#{n.to_s.rjust(3)} #{exp}"
      end
      nil
    end
  end
end
