require "fileutils"
require "rubycritic/generators/html/overview"
require "rubycritic/generators/html/smells_index"
require "rubycritic/generators/html/code_index"
require "rubycritic/generators/html/code_file"

module Rubycritic
  module Generator

    class HtmlReport
      ASSETS_DIR = File.expand_path("../html/assets", __FILE__)

      def initialize(analysed_modules)
        @analysed_modules = analysed_modules
        @gpa = calculate_gpa(analysed_modules)
      end

      def generate_report
        create_directories_and_files
        copy_assets_to_report_directory
        puts "New critique at #{report_location}"
        check_letter_threshold(@analysed_modules)
        abort "Failing because GPA is to low, " \
          "should be #{Config.gpa_threshold} but is #{@gpa.round(2)}" if @gpa < Config.gpa_threshold
      end

      private

      def create_directories_and_files
        Array(generators).each do |generator|
          FileUtils.mkdir_p(generator.file_directory)
          File.open(generator.file_pathname, "w+") do |file|
            file.write(generator.render)
          end
        end
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


      def generators
        [overview_generator, code_index_generator, smells_index_generator] + file_generators
      end

      def overview_generator
        @overview_generator ||= Html::Overview.new(@analysed_modules, @gpa)
      end

      def code_index_generator
        Html::CodeIndex.new(@analysed_modules)
      end

      def smells_index_generator
        Html::SmellsIndex.new(@analysed_modules)
      end

      def file_generators
        @analysed_modules.map do |analysed_module|
          Html::CodeFile.new(analysed_module)
        end
      end

      def copy_assets_to_report_directory
        FileUtils.cp_r(ASSETS_DIR, Config.root)
      end

      def report_location
        overview_generator.file_href
      end
    end

  end
end
