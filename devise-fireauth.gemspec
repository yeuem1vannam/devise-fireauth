
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "devise/fireauth/version"

Gem::Specification.new do |spec|
  spec.name          = "devise-fireauth"
  spec.version       = Devise::Fireauth::VERSION
  spec.authors       = ["yeuem1vannam"]

  spec.summary       = %q{Firebase as authentication service}
  spec.description   = %q{Firebase as authentication service behind the devise}
  spec.homepage      = "https://github.com/yeuem1vannam/devise-fireauth"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 4"
  spec.add_runtime_dependency "devise", "~> 4.0"
  spec.add_runtime_dependency "dry-configurable"
  spec.add_runtime_dependency "jwt", ">= 1"
  spec.add_runtime_dependency "warden"

  spec.add_development_dependency "activemodel" # required by devise
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "openssl"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "railties", ">= 4"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-github"
  spec.add_development_dependency "rubocop-rspec"
end
