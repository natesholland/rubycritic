require "pathname"

module Rubycritic
  module Generator

    class Base
      def file_href
        "file://#{file_pathname}"
      end

      def file_pathname
        File.join(file_directory, file_name)
      end

      def file_directory
        @file_directory ||= root_directory
      end

      def file_name
        raise NotImplementedError.new("The #{self.class} class must implement the #{__method__} method.")
      end

      def render
        raise NotImplementedError.new("The #{self.class} class must implement the #{__method__} method.")
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

      private

      def root_directory
        @root_directory ||= Pathname.new(Config.root)
      end
    end

  end
end
