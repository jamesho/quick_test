require 'quick_test/quick_test'
require 'quick_test/experiment'
require 'quick_test/parameter'
require 'quick_test/result'
require 'quick_test/test_runner'

# TODO: run tests that failed the last time
# TODO: figure out how to reload helpers
# TODO: get functional tests to work
# TODO: blueprints don't get updated
# TODO: reports2_test doesn't seem to work the second time around
# TODO: get line number out
module QuickTest
  class << self
    def start
      QuickTest.new
    end
  end
end

# monkey patching!
module Test
  module Unit
    # Encapsulates a test failure. Created by Test::Unit::TestCase
    # when an assertion fails.
    class Failure
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
    end
  end
end

module Test
  module Unit
    class Error
      # Returns a single character representation of an error.
      def single_character_display
        SINGLE_CHARACTER.color(:red)
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
    end
  end
end
