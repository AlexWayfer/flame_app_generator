# frozen_string_literal: true

require_relative 'lib/flame_app_generator/version'

Gem::Specification.new do |spec|
	spec.name        = 'flame_app_generator'
	spec.version     = FlameAppGenerator::VERSION
	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']

	spec.summary     = 'Generator for Flame web applications'
	spec.description = <<~DESC
		Generator for Flame web applications.
	DESC
	spec.license = 'MIT'

	spec.required_ruby_version = '>= 3.0', '< 4'

	github_uri = "https://github.com/AlexWayfer/#{spec.name}"

	spec.homepage = github_uri

	spec.metadata = {
		'rubygems_mfa_required' => 'true',
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
		# 'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'homepage_uri' => spec.homepage,
		'source_code_uri' => github_uri
		# 'wiki_uri' => "#{github_uri}/wiki"
	}

	files = %w[
		lib/**/*.rb
		template/**/*
		README.md
		LICENSE.txt
		CHANGELOG.md
	]
	spec.files = Dir.glob "{#{files.join(',')}}", File::FNM_DOTMATCH
	spec.bindir = 'exe'
	spec.executables.concat.push 'flame_app_generator'

	spec.add_dependency 'gorilla_patch', '~> 5.0'
	spec.add_dependency 'project_generator', '~> 0.4.0'
end
