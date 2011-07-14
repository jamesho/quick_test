module QuickTest
  class Configuration
    attr_accessor :show_metrics
    attr_accessor :threshold_slow_warning
    attr_accessor :threshold_slow_error

    def initialize options={}
      self.show_metrics = true
      self.threshold_slow_warning = 0.5
      self.threshold_slow_error = 1

      configure options
    end

    def configure options={}
      self.show_metrics = options[:show_metrics] if options.has_key?(:show_metrics)
      self.threshold_slow_warning = options[:threshold_slow_warning] if options.has_key?(:threshold_slow_warning)
      self.threshold_slow_error = options[:threshold_slow_error] if options.has_key?(:threshold_slow_error)
    end
  end
end
