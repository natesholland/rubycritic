require "fileutils"
require "rubycritic/generators/html/overview"
require "rubycritic/generators/html/smells_index"
require "rubycritic/generators/html/code_index"
require "rubycritic/generators/html/code_file"

module Rubycritic
  module Generator

    class HtmlReport < Base
      ASSETS_DIR = File.expand_path("../html/assets", __FILE__)

      def initialize(analysed_modules)
        @analysed_modules = analysed_modules
        @gpa = calculate_gpa(analysed_modules)
      end

      def generate_report
        create_directories_and_files
        copy_assets_to_report_directory
        puts "New critique at #{report_location}"
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
