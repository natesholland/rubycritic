require "test_helper"
require "rubycritic/generators/global_rating_calculator"
require "rubycritic/core/analysed_module"
require "rubycritic/configuration"

describe Rubycritic::Generator::GlobalRatingCalculator do
  include Rubycritic::Generator::GlobalRatingCalculator

  it "calculates the gpa" do
    smells1 = [SmellDouble.new(:cost => 1), SmellDouble.new(:cost => 2)]
    smells2 = [SmellDouble.new(:cost => 10), SmellDouble.new(:cost => 12)]
    am1 = Rubycritic::AnalysedModule.new(:smells => smells1, :complexity => 0, :lines => 25)
    am2 = Rubycritic::AnalysedModule.new(:smells => smells2, :complexity => 0, :lines => 10)
    analysed_modules = [am1, am2]
    gpa = calculate_gpa(analysed_modules)
    gpa.round(2).must_equal 2.14
  end

  it "checks the letter threshold and exits" do
    orig_stderr = $stderr.clone
    $stderr.reopen File.new("/dev/null", "w")
    Rubycritic::Config.set(:letter_threshold => 8.0)
    smells1 = [SmellDouble.new(:cost => 1), SmellDouble.new(:cost => 2)]
    smells2 = [SmellDouble.new(:cost => 100), SmellDouble.new(:cost => 100)]
    am1 = Rubycritic::AnalysedModule.new(:smells => smells1, :complexity => 0, :lines => 25)
    am2 = Rubycritic::AnalysedModule.new(:smells => smells2, :complexity => 0, :lines => 10)
    analysed_modules = [am1, am2]
    assert_raises(SystemExit) { check_letter_threshold(analysed_modules) }
    $stderr.reopen orig_stderr
  end
end
