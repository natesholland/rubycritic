module Rubycritic
  module Generator
    module GlobalRatingCalculator
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
    end
  end
end
