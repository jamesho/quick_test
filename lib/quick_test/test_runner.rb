require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'
require 'test/unit/ui/console/testrunner'

# Runs a Test::Unit::TestSuite on the console.
module QuickTest
  class TestRunner < Test::Unit::UI::Console::TestRunner
    attr_accessor :seconds_per_test
    attr_accessor :configuration

    def initialize(configuration, suite, output_level=Test::Unit::UI::NORMAL, io=STDOUT)
      super suite, output_level, io
      self.configuration = configuration
      self.seconds_per_test = {}
      @start_time = nil
    end

    def faults
      @faults
    end

    def test_started(name)
      super
      @start_time = Time.now
      output_single(name + ": ", Test::Unit::UI::VERBOSE)
    end

    def test_finished(name)
      duration = Time.now - @start_time
      self.seconds_per_test[name] = duration

      if duration > self.configuration.threshold_slow_error and self.configuration.show_metrics
        output_single("O".color(:yellow).bright, Test::Unit::UI::PROGRESS_ONLY) unless (@already_outputted)
        nl(Test::Unit::UI::VERBOSE)
        @already_outputted = false
      elsif duration > self.configuration.threshold_slow_warning and self.configuration.show_metrics
        output_single("o".color(:yellow).bright, Test::Unit::UI::PROGRESS_ONLY) unless (@already_outputted)
        nl(Test::Unit::UI::VERBOSE)
        @already_outputted = false
      else
        super
      end
    end
  end
end
=begin
  private
    def attach_to_mediator
      @mediator.add_listener(Test::Unit::TestResult::FAULT, &method(:add_fault))
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:finished))
      @mediator.add_listener(Test::Unit::TestCase::STARTED, &method(:test_started))
      @mediator.add_listener(Test::Unit::TestCase::FINISHED, &method(:test_finished))
    end

    def start_mediator
      return @mediator.run_suite
    end

    def add_fault(fault)
      @faults << fault
      output_single(fault.single_character_display, Test::Unit::UI::PROGRESS_ONLY)
      @already_outputted = true
    end

    def started(result)
      @result = result
      output("Started")
    end

    def finished(elapsed_time)
      nl
      output("Finished in #{elapsed_time} seconds.")
      @faults.each_with_index do |fault, index|
        nl
        output("%3d) %s" % [index + 1, fault.long_display])
      end
      nl
      output(@result)
    end

    def test_started(name)
      output_single(name + ": ", Test::Unit::UI::VERBOSE)
    end

    def test_finished(name)
      output_single(".", Test::Unit::UI::PROGRESS_ONLY) unless (@already_outputted)
      nl(Test::Unit::UI::VERBOSE)
      @already_outputted = false
    end

    def nl(level=Test::Unit::UI::NORMAL)
      output("", level)
    end

    def output(something, level=Test::Unit::UI::NORMAL)
      @io.puts(something) if (output?(level))
      @io.flush
    end

    def output_single(something, level=Test::Unit::UI::NORMAL)
      @io.write(something) if (output?(level))
      @io.flush
    end

    def output?(level)
      level <= @output_level
    end
=end
