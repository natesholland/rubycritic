module Rubycritic
  class Configuration
    attr_reader :root
    attr_accessor :source_control_system, :mode, :format, :deduplicate_symlinks,
      :suppress_ratings, :gpa_threshold, :letter_threshold

    def set(options)
      self.mode = options.fetch(:mode) { :default }
      self.root = options[:root] || "tmp/rubycritic"
      self.format = options.fetch(:format) { :html }
      self.deduplicate_symlinks = options.fetch(:deduplicate_symlinks) { false }
      self.suppress_ratings = options.fetch(:suppress_ratings) { false }
      self.gpa_threshold = options.fetch(:gpa_threshold) { 0.0 }
      self.letter_threshold = options[:letter_threshold]
    end

    def root=(path)
      @root = File.expand_path(path)
    end
  end

  module Config
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.set(options = {})
      configuration.set(options)
    end

    def self.method_missing(method, *args, &block)
      configuration.public_send(method, *args, &block)
    end
  end
end
