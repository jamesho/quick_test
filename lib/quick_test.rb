require 'test/unit'
require 'quick_test/quick_test_runner'
require 'quick_test/experiment'
require 'quick_test/result'
require 'quick_test/parameter'

# TODO: run tests that failed the last time
# TODO: figure out how to reload helpers
# TODO: get functional tests to work
# TODO: blueprints don't get updated
# TODO: reports2_test doesn't seem to work the second time around
# TODO: get line number out
module QuickTest

  class << self
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
  self.experiments = []
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

# monkey patching!
module Test
  module Unit

    # Encapsulates a test failure. Created by Test::Unit::TestCase
    # when an assertion fails.
    class Failure
      attr_reader :test_name, :location, :message

      SINGLE_CHARACTER = 'F'

      # Creates a new Failure with the given location and
      # message.
      def initialize(test_name, location, message)
        @test_name = test_name
        @location = highlight_useful_lines(location)
        @message = message
      end

      def highlight_useful_lines location
        name = self.test_name[/(.*)\(.*\)$/,1]

        location.collect do |l|
          if l.include?(name)
            l.color(:green).bright
          elsif (l.start_with?("app/") or l.start_with?("lib/"))
            l.color("#FFFF00")
          else
            l.color("#FFC482")
          end

        end
      end

      # Returns a single character representation of a failure.
      def single_character_display
        SINGLE_CHARACTER.color(:red)
      end

      # Returns a brief version of the error description.
      def short_display
        "#@test_name: #{@message.split("\n")[0]}"
      end

      # Returns a verbose version of the error description.
      def long_display
        location_display = if(location.size == 1)
          location[0].sub(/\A(.+:\d+).*/, ' [\\1]')
        else
          "\n    [#{location.join("\n     ")}]"
        end
        "Failure:\n#@test_name#{location_display}:\n#@message"
      end

      # Overridden to return long_display.
      def to_s
        long_display
      end
    end
  end
end

module Test
  module Unit

    # Encapsulates an error in a test. Created by
    # Test::Unit::TestCase when it rescues an exception thrown
    # during the processing of a test.
    class Error
      include Util::BacktraceFilter

      attr_reader(:test_name, :exception)

      SINGLE_CHARACTER = 'E'

      # Creates a new Error with the given test_name and
      # exception.
      def initialize(test_name, exception)
        @test_name = test_name
        @exception = exception
      end

      # Returns a single character representation of an error.
      def single_character_display
        SINGLE_CHARACTER.color(:red)
      end

      # Returns the message associated with the error.
      def message
        "#{@exception.class.name}: #{@exception.message}"
      end

      # Returns a brief version of the error description.
      def short_display
        "#@test_name: #{message.split("\n")[0]}"
      end

      # Returns a verbose version of the error description.
      def long_display
        backtrace = highlight_useful_lines(filter_backtrace(@exception.backtrace)).join("\n    ")
        "Error:\n#@test_name:\n#{message}\n    #{backtrace}"
      end

      def highlight_useful_lines backtrace
        name = self.test_name[/(.*)\(.*\)$/,1]

        backtrace.collect do |bt|
          if bt.include?(name)
            bt.color(:green).bright
          elsif (bt.start_with?("/app/") or bt.start_with?("app/") or bt.start_with?("/lib/") or bt.start_with?("lib/"))
            bt.color("#FFFF00")
          else
            bt.color("#FFC482")
          end
        end
      end

      # Overridden to return long_display.
      def to_s
        long_display
      end
    end
  end
end
