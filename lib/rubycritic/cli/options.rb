require "optparse"

module Rubycritic
  module Cli
    class Options
      def initialize(argv)
        @argv = argv
        @parser = OptionParser.new
      end

      # rubocop:disable Metrics/MethodLength
      def parse
        @parser.new do |opts|
          opts.banner = "Usage: rubycritic [options] [paths]"

          opts.on("-p", "--path [PATH]", "Set path where report will be saved (tmp/rubycritic by default)") do |path|
            @root = path
          end

          opts.on(
            "-f", "--format [FORMAT]",
            [:html, :json],
            "Report smells in the given format:",
            "  html (default)",
            "  json"
          ) do |format|
            @format = format
          end

          opts.on(
            "-g", "--gpa-threshold [THRESHOLD]", "Fail the build if gpa falls below threshold"
          ) do |threshold|
            @gpa_threshold = threshold.to_f
          end

          opts.on(
            "-l", "--letter-threshold [THRESHOLD]", "Fail the build if a single class falls below the threshold"
          ) do |threshold|
            if threshold == "F"
              @letter_threshold = 16
            elsif threshold == "D"
              @letter_threshold = 8
            elsif threshold == "C"
              @letter_threshold = 4
            elsif threshold == "B"
              @letter_threshold = 2
            elsif threshold == "A"
              @letter_threshold = 0
            else
              @letter_threshold = nil
            end
          end


          opts.on("-m", "--mode-ci", "Use CI mode (faster, but only analyses last commit)") do
            @mode = :ci
          end

          opts.on("--deduplicate-symlinks", "De-duplicate symlinks based on their final target") do
            @deduplicate_symlinks = true
          end

          opts.on("--suppress-ratings", "Suppress letter ratings") do
            @suppress_ratings = true
          end

          opts.on_tail("-v", "--version", "Show gem's version") do
            @mode = :version
          end

          opts.on_tail("-h", "--help", "Show this message") do
            @mode = :help
          end
        end.parse!(@argv)
        self
      end

      def help_text
        @parser.help
      end

      def to_h
        {
          :mode => @mode,
          :root => @root,
          :format => @format,
          :deduplicate_symlinks => @deduplicate_symlinks,
          :paths => paths,
          :suppress_ratings => @suppress_ratings,
          :gpa_threshold => @gpa_threshold,
          :letter_threshold => @letter_threshold
        }
      end

      private

      def paths
        if @argv.empty?
          ["."]
        else
          @argv
        end
      end
    end
  end
end
