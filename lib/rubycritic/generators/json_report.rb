require "rubycritic/generators/json/simple"

module Rubycritic
  module Generator

    class JsonReport
      def initialize(analysed_modules)
        @analysed_modules = analysed_modules
        @gpa = calculate_gpa(analysed_modules)
      end

      def generate_report
        print generator.render
        check_letter_threshold(analysed_modules)
        abort "Failing because GPA is to low, " \
          "should be #{Config.gpa_threshold} but is #{@gpa.round(2)}" if @gpa < Config.gpa_threshold
      end

      def calculate_gpa(analysed_modules)
        gpa_sum = 0
        total_lines = 0
        analysed_modules.map do |analysed_module|
          gpa_sum += (analysed_module.rating.to_gpa) * analysed_module.lines
          total_lines += analysed_module.lines
        end
        gpa_sum / total_lines
      end

      def check_letter_threshold(analysed_modules)
        return unless Config.letter_threshold
        analysed_modules.each do |analysed_module|
          abort "#{analysed_module.path} fellow below the threshold " \
          "of #{Rating.from_cost(Config.letter_threshold)}" if analysed_module.cost > Config.letter_threshold
        end
      end

      private

      def generator
        @generator ||= Json::Simple.new(@analysed_modules, @gpa)
      end
    end

  end
end
