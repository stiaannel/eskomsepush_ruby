# frozen_string_literal: true

require_relative "lib/eskomsepush/version"

Gem::Specification.new do |spec|
  spec.name = "eskomsepush_ruby"
  spec.version = EskomSePush::VERSION
  spec.authors = ["stiaannel"]
  spec.email = ["christiaannel9@gmail.com"]

  spec.summary = "EskomSePush API Wrapper Rubygem"
  spec.description = "EskomSePush API Wrapper Rubygem"
  spec.homepage = "https://github.com/stiaannel/eskomsepush_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stiaannel/eskomsepush_ruby"
  spec.metadata["changelog_uri"] = "https://github.com/stiaannel/eskomsepush_ruby/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://stiaannel.co.za/eskomsepush_ruby/"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "faraday", "~> 2.7.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
