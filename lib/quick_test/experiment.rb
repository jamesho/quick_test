module QuickTest
  class Experiment
    attr_accessor :parameter
    attr_accessor :results
    attr_accessor :frozen_result
    attr_accessor :configuration

    def initialize configuration, test_path, keyword
      self.results = []
      self.parameter = Parameter.new test_path, keyword
      self.configuration = configuration
    end

    def run
      unless self.parameter.valid?
        puts "Parameter error!"
      end

      # reload needs to be done before load otherwise can't load the unit tests that are nested in modules/folders
      reload!
      test_class = self.parameter.load_test_class
      test_names = self.parameter.test_names

      internal_run test_class, test_names
    end

    def freeze_result
      self.frozen_result = self.results.last
    end

    def unfreeze_result
      self.frozen_result = nil
    end

    def output_metrics number=nil
      result = number ? self.results[number] : self.results.last
      result.output_metrics self.configuration
    end

    def run_faults
      result = self.frozen_result || self.results.last

      reload!
      test_class = self.parameter.load_test_class
      test_names = result.fault_test_names

      internal_run test_class, test_names
    end

    def result number
      self.results[number]
    end

    def list
      self.parameter.list + [self.results.size]
    end

  private
    def internal_run test_class, test_names
      test_suite = Test::Unit::TestSuite.new(test_class.to_s)
      test_names.each do |tn|
        test_suite << test_class.new(tn)
      end

      begin
        # handle helper tests and forcibly load in the latest helper
        if test_class.to_s.include?("HelperTest")
          helper = test_class.helper_class

          load "app/helpers/#{helper.to_s.underscore}.rb"
          test_class.tests(helper)
        end

        runner = TestRunner.new(self.configuration, test_suite)
        runner.start

        result = Result.new(runner)
        result.output_metrics(self.configuration) if self.configuration.show_metrics
        self.results << result

        if self.parameter.tests_filtered?
          test_suite.tests.each {|t| puts "    #{t.method_name}"}
        end

      ensure
        clean test_class, test_names, false
      end
    end

    # necessary to "undef" test methods so that we can reload them again
    # (via load "test/unit...") so that any changes made to the test file get through
    def clean test_class, test_names, verbose=true
      test_class.suite.tests.each do |a|
        begin
          test_class.send(:remove_method, a.method_name)
        rescue
          puts "couldn't remove: #{a.method_name}"
        end
      end

      console_puts "Successfully cleaned test names" if verbose
    end
  end
end
