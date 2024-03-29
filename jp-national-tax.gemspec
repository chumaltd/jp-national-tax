lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jp_national_tax/version"

Gem::Specification.new do |spec|
  spec.name          = "jp-national-tax"
  spec.version       = JpNationalTax::VERSION
  spec.authors       = ["Chuma Takahiro"]
  spec.email         = ["co.chuma@gmail.com"]

  spec.summary       = %q{Tax calculation libs for Japan National tax}
  spec.description   = <<~DESC
    Tax calculation libs for Japan National tax
  DESC
  spec.homepage      = "https://github.com/chumaltd/jp-national-tax"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/chumaltd/jp-national-tax"
    spec.metadata["changelog_uri"] = "https://github.com/chumaltd/jp-national-tax/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "minitest", "~> 5.0"
end
