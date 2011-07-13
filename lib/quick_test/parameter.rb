module QuickTest
class Parameter
  attr_accessor :test_path, :keyword
  attr_accessor :test_class

  def initialize test_path, keyword
    self.test_path = test_path
    self.keyword = keyword
  end

  def test_file
    "test/unit/#{self.test_path}_test.rb"
  end

  def load_test_class
    load test_file
    self.test_class = begin
     "#{self.test_path.split('/').last.camelize}Test".constantize
    rescue NameError
      "#{self.test_path.camelize}Test".constantize
    end
    self.test_class
  end

  def test_names
    names = self.test_class.suite.tests.collect do |t|
      if self.keyword.blank?
        t.method_name
      else
        t.method_name if t.method_name.include?(self.keyword)
      end
    end.compact
  end

  def valid?
    true
  end

  def tests_filtered?
    !self.keyword.blank?
  end

  def to_s
    desc = self.test_path.ljust(20) + " "
    desc << (self.keyword.blank? ? "".ljust(10) : self.keyword.ljust(10))
    desc
  end
end
end
