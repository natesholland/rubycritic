require "fileutils"
require "rubycritic/generators/json/simple"

module Rubycritic
  module Generator

    class JsonReport
      def initialize(analysed_modules)
        @analysed_modules = analysed_modules
      end

      def generate_report
        create_directories_and_files
        calculate_gpa
        puts "New JSON critique at #{report_location}"
      end

      private

      def create_directories_and_files
        FileUtils.mkdir_p(generator.file_directory)
        File.open(generator.file_pathname, "w+") do |file|
          file.write(generator.render)
        end
      end

      def calculate_gpa
        gpa_sum = 0
        total = @analysed_modules.map do |analysed_module|
          gpa_sum += analysed_module.rating.to_gpa
        end.count
        puts "Overal Project GPA: #{(gpa_sum / total).to_s[0..3]}"
        gpa_sum / total
      end

      def generator
        @generator ||= Json::Simple.new(@analysed_modules)
      end

      def report_location
        generator.file_href
      end
    end

  end
end
