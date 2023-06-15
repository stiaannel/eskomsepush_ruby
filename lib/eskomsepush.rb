# frozen_string_literal: true

require_relative "eskomsepush/version"

module EskomSePush
  class Error < StandardError; end
  # Your code goes here...
  class Setup
    def self.greet
      puts "Hello World"
    end
  end
end
