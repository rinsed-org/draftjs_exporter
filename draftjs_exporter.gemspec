# -*- encoding: utf-8 -*-
# stub: draftjs_exporter 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "draftjs_exporter".freeze
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Theo Cushion".freeze]
  s.date = "2020-09-22"
  s.description = "Draft.js is a framework for building rich text editors. However, it does not support exporting documents at\nHTML. This gem is designed to take the raw `ContentState` (output of `convertToRaw`) from Draft.js and convert\nit to HTML using Ruby.\n".freeze
  s.email = "theo@ignition.works".freeze
  s.files = ["LICENSE.md".freeze, "README.md".freeze, "lib/draftjs_exporter.rb".freeze, "lib/draftjs_exporter/atomic/base.rb".freeze, "lib/draftjs_exporter/blocks/base.rb".freeze, "lib/draftjs_exporter/command.rb".freeze, "lib/draftjs_exporter/entities/link.rb".freeze, "lib/draftjs_exporter/entities/null.rb".freeze, "lib/draftjs_exporter/entity_state.rb".freeze, "lib/draftjs_exporter/error.rb".freeze, "lib/draftjs_exporter/html.rb".freeze, "lib/draftjs_exporter/style_state.rb".freeze, "lib/draftjs_exporter/version.rb".freeze, "lib/draftjs_exporter/wrapper_state.rb".freeze, "spec/integrations".freeze, "spec/integrations/html_spec.rb".freeze, "spec/integrations/requires_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://github.com/ignitionworks/draftjs_exporter".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Export Draft.js content state into HTML".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.6", ">= 1.6.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4", ">= 3.4.0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.40", ">= 0.40.0"])
    s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.5", ">= 0.5.0"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.11", ">= 0.11.0"])
    s.add_development_dependency(%q<rails>.freeze, ["~> 6.0", ">= 6.0.3.2"])
  else
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6", ">= 1.6.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4", ">= 3.4.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.40", ">= 0.40.0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, ["~> 0.5", ">= 0.5.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.11", ">= 0.11.0"])
  end
end
