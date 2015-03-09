require "rubycritic/generators/json/simple"
require "rubycritic/generators/global_rating_calculator"

module Rubycritic
  module Generator

    class JsonReport
      include GlobalRatingCalculator

      def initialize(analysed_modules)
        @analysed_modules = analysed_modules
        @gpa = calculate_gpa(analysed_modules)
      end

      def generate_report
        print generator.render
        check_letter_threshold(@analysed_modules)
        abort "Failing because GPA is to low, " \
          "should be #{Config.gpa_threshold} but is #{@gpa.round(2)}" if
          Config.gpa_threshold && @gpa < Config.gpa_threshold
      end

      private

      def generator
        @generator ||= Json::Simple.new(@analysed_modules, @gpa)
      end
    end

  end
end
