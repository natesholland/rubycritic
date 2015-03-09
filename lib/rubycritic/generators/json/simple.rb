require "json"

module Rubycritic
  module Generator
    module Json

      class Simple
        def initialize(analysed_modules, gpa)
          @analysed_modules = analysed_modules
          @gpa = gpa
        end

        def file_name
          "rubycritic.json"
        end

        def render
          JSON.dump(data)
        end

        def data
          {
            :metadata => {
              :rubycritic => {
                :version => Rubycritic::VERSION
              }
            },
            :gpa => @gpa,
            :analysed_modules => @analysed_modules
          }
        end
      end

    end
  end
end