# frozen_string_literal: true

require 'bundler'
require 'project_generator'

require_relative 'command/process_files'

## https://github.com/mdub/clamp#allowing-options-after-parameters
Clamp.allow_options_after_parameters = true

module FlameAppGenerator
	## Main CLI command for Flame App Generator
	class Command < ProjectGenerator::Command
		include ProcessFiles

		parameter 'NAME', 'name of a new application'
		parameter 'TEMPLATE', 'template path of a new app'

		option ['-d', '--domain'], 'NAME', 'domain name for configuration'
		option ['-p', '--project-name'], 'NAME', 'project name for code and configuration'

		def execute
			check_target_directory

			refine_template_parameter if git?

			process_files

			clean_dirs

			initialize_git

			setup_project

			FileUtils.rm_r @git_tmp_dir if git?

			done
		end

		private

		def clean_dirs
			puts 'Clean directories...'

			Dir.chdir name do
				FileUtils.rm Dir.glob('**/.keep', File::FNM_DOTMATCH)
			end
		end

		def setup_project
			puts 'Setup project...'

			Dir.chdir name do
				Bundler.with_unbundled_env do
					system 'exe/setup.sh'
				end
			end
		end
	end
end
