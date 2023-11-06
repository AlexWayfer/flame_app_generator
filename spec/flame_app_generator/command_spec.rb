# frozen_string_literal: true

require 'inifile'

describe FlameAppGenerator::Command do
	describe '.run' do
		subject(:run) do
			described_class.run('flame_app_generator', args)
		end

		## I'd like to use `instance_double`, but it doesn't support `and_call_original`
		let(:command_instance) { described_class.new('flame_app_generator') }

		before do
			# allow(command_instance).to receive(:run).and_call_original
			allow(described_class).to receive(:new).and_return command_instance
		end

		context 'without app name parameter' do
			let(:args) { [] }

			it do
				expect { run }.to raise_error(SystemExit).and output(
					/ERROR: parameter 'NAME': no value provided/
				).to_stderr
			end
		end

		context 'with app name parameter' do
			let(:app_name) { 'foo_bar' }
			let(:args) { [app_name] }

			shared_context 'with supressing regular output' do
				before do
					[
						'Copying files...',
						'Renaming files...',
						'Rendering files...',
						'Clean directories...',
						'Setup project...',
						'Initializing git...',
						no_args,
						'Done.',
						"To checkout into a new directory:\n\tcd foo_bar\n"
					].each do |line|
						allow($stdout).to receive(:puts).with(line)
					end
				end
			end

			context 'without template parameter' do
				it do
					expect { run }.to raise_error(SystemExit).and output(
						/ERROR: parameter 'TEMPLATE': no value provided/
					).to_stderr
				end
			end

			context 'with template parameter' do
				let(:args) { [*super(), template] }

				before do
					allow(command_instance).to receive(:system).with('git init')
					allow(command_instance).to receive(:system).with('git add .')
					allow(command_instance).to receive(:system).with('exe/setup.sh')
				end

				after do
					FileUtils.rm_r app_name if Dir.exist? app_name
				end

				shared_examples 'correct behavior with template' do
					shared_examples 'common correct system calls with all data' do
						specify do
							expect(command_instance).to have_received(:system).with('git init').once
						end

						specify do
							expect(command_instance).to have_received(:system).with('exe/setup.sh').once
						end
					end

					shared_examples 'common correct files with all data' do
						describe 'config.ru.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'config.ru'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									"#{short_module_name}::Application.setup",
									"if #{short_module_name}::Application.config[:session]",
									<<~LINE.chomp,
										use Rack::Session::Cookie, #{short_module_name}::Application.config[:session][:cookie]
									LINE
									"use Rack::CommonLogger, #{short_module_name}::Application.logger",
									"#{short_module_name}::App = #{short_module_name}::Application",
									"run #{short_module_name}::Application"
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe 'constants.rb.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'constants.rb'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									"module #{module_name}",
									"::#{short_module_name} = self"
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe 'controllers/site/index_controller.rb.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'controllers/site/index_controller.rb'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									"module #{module_name}",
									'class IndexController < Site::Controller'
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe 'README.md.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'README.md'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									"# #{module_name}",
									"`createuser -U postgres #{app_name}`",
									"*   Add UNIX-user for project: `adduser #{app_name}`",
									"*   Make symbolic link of project directory to `/var/www/#{app_name}`"
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe 'config/mail.example.yaml.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'config/mail.example.yaml'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									":name: '#{email_from_name}'",
									":email: 'info@#{domain_name}'",
									":user_name: 'info@#{domain_name}'"
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe 'config/session.example.yaml.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'config/session.example.yaml'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									/^\s+:expire_after: 2592000 # 30 days/,
									/^\s+:secret: '[a-zA-Z0-9]{64}'$/,
									/^\s+# :old_secret: ''/
								]
							end

							it { is_expected.to match_lines expected_lines }
						end

						describe 'views/site/layout.html.erb.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, app_name, 'views/site/layout.html.erb'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									'<title><%= config[:site][:site_name] %></title>',
									'<%',
									'<% end %>',
									<<~LINE.chomp,
										type="text/javascript" src="<%= url_to "/scripts/compiled/sentry.js", version: true %>"
									LINE
									"dsn: '<%= config[:sentry]['front-end'][:url] %>',",
									"environment: '<%= config[:environment] %>',",
									"release: '<%= Sentry.configuration.release %>',",
									'// Sentry.setUser(<%= authenticated&.account&.to_json %>)',
									'<% file_names.each do |name| %>',
									<<~LINE.chomp,
										type="text/javascript" src="<%= url_to "/scripts/\#{dir}/\#{name}.js", version: true %>"
									LINE
									"<a href=\"<%= path_to #{short_module_name}::Site::IndexController %>\">",
									'<h1><%= config[:site][:site_name] %></h1>',
									'<%# if @menu %>',
									'<%#',
									'<%# items.each do |item| %>',
									'href="<%#= path_to item.controller %>"',
									"class=\"<%#= 'selected' if item.current? %>\"",
									'><%#=',
									'<%# end %>',
									'<div class="flash <%#= type %>">',
									'<%#= text %>',
									"href=\"<%= path_to #{short_module_name}::Site::IndexController %>\"",
									'><%= config[:site][:site_name] %></a>,',
									"#{Date.today.year}"
								]
							end

							it { is_expected.to include_lines expected_lines }
						end

						describe '.editorconfig' do
							subject(:ini_file) do
								IniFile.load(File.join(Dir.pwd, app_name, '.editorconfig')).to_h
							end

							context 'with default indentation (tabs)' do
								let(:expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'tab',
											'indent_size' => 2
										)
									)
								end

								let(:not_expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'space'
										)
									)
								end

								specify do
									run ## parent subject with generation

									expect(ini_file).to match(expected_values).and not_match(not_expected_values)
								end

								describe 'config.ru indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'config.ru'))
									end

									before do
										run ## parent subject with generation
									end

									specify do
										expect(file_content).to match(
											/^\t#{short_module_name}::App = #{short_module_name}::Application$/
										)
									end

									it { is_expected.not_to match(/^  /) }
								end

								describe 'YAML indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'config/mail.example.yaml'))
									end

									before do
										run ## parent subject with generation
									end

									it { is_expected.to match(/^  :host: localhost$/) }

									it { is_expected.not_to match(/^\t/) }
								end

								describe 'Markdown indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'README.md'))
									end

									before do
										run ## parent subject with generation
									end

									it { is_expected.to match(/^    2.  Create a project user:$/) }

									it { is_expected.not_to match(/^\t/) }
								end
							end

							context 'with spaces indentation' do
								let(:args) do
									[*super(), '--indentation=spaces']
								end

								let(:expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'space',
											'indent_size' => 2
										)
									)
								end

								let(:not_expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'tab'
										)
									)
								end

								specify do
									run ## parent subject with generation

									expect(ini_file).to match(expected_values).and not_match(not_expected_values)
								end

								describe 'config.ru indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'config.ru'))
									end

									before do
										run ## parent subject with generation
									end

									specify do
										expect(file_content).to match(
											/^  #{short_module_name}::App = #{short_module_name}::Application$/
										)
									end

									it { is_expected.not_to match(/^\t/) }
								end

								describe 'YAML indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'config/mail.example.yaml'))
									end

									before do
										run ## parent subject with generation
									end

									it { is_expected.to match(/^  :host: localhost$/) }

									it { is_expected.not_to match(/^\t/) }
								end

								describe 'Markdown indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, app_name, 'README.md'))
									end

									before do
										run ## parent subject with generation
									end

									it { is_expected.to match(/^    2.  Create a project user:$/) }

									it { is_expected.not_to match(/^\t/) }
								end
							end

							context 'with incorrect indentation' do
								let(:args) do
									[*super(), '--indentation=foo']
								end

								let(:expected_stderr) do
									<<~OUTPUT
										ERROR: option '--indentation': Only `tabs` or `spaces` values acceptable

										See: 'flame_app_generator --help'
									OUTPUT
								end

								specify do
									expect { run }.to raise_error(SystemExit).and(
										not_output.to_stdout.and(
											output(expected_stderr).to_stderr
										)
									)
								end
							end
						end
					end

					shared_examples 'common correct behavior with all data' do
						describe 'output' do
							let(:expected_output_start) do
								## There is allowed prompt
								<<~OUTPUT
									Copying files...
									Renaming files...
									Rendering files...
									Clean directories...
									Initializing git...
									Setup project...
								OUTPUT
							end

							let(:expected_output_end) do
								<<~OUTPUT
									Done.
									To checkout into a new directory:
										cd #{app_name}
								OUTPUT
							end

							specify do
								expect { run }.to output(
									a_string_starting_with(expected_output_start)
										.and(ending_with(expected_output_end))
								).to_stdout_from_any_process.and not_output.to_stderr_from_any_process
							end
						end

						describe 'system calls' do
							include_context 'with supressing regular output'

							before do
								run
							end

							include_examples 'correct system calls with all data'
						end

						describe 'files' do
							include_context 'with supressing regular output'

							include_examples 'correct files with all data'
						end
					end

					context 'without project name option' do
						let(:module_name) { 'FooBar' }
						let(:short_module_name) { 'FB' }

						context 'without domain option' do
							let(:domain_name) { 'foobar.com' }
							let(:email_from_name) { 'FooBar.com' }

							include_examples 'correct behavior with all data'
						end

						context 'with domain option' do
							let(:domain_name) { 'foo-bar.ru' }
							let(:email_from_name) { 'FooBar.ru' }

							let(:args) do
								[*super(), "--domain=#{domain_name}"]
							end

							include_examples 'correct behavior with all data'
						end
					end

					context 'with project name option' do
						let(:project_name) { 'FooBaR' }

						let(:module_name) { 'FooBaR' }
						let(:short_module_name) { 'FBR' }

						let(:args) do
							[*super(), "--project-name=#{project_name}"]
						end

						context 'without domain option' do
							let(:domain_name) { 'foobar.com' }
							let(:email_from_name) { 'FooBaR.com' }

							include_examples 'correct behavior with all data'
						end

						context 'with domain option' do
							let(:domain_name) { 'foo-bar.ru' }
							let(:email_from_name) { 'FooBaR.ru' }

							let(:args) do
								[*super(), "--domain=#{domain_name}"]
							end

							include_examples 'correct behavior with all data'
						end
					end
				end

				context 'when this template is local (by default)' do
					let(:template) { "#{__dir__}/../support/example_template" }

					shared_examples 'correct system calls with all data' do
						include_examples 'common correct system calls with all data'
					end

					shared_examples 'correct files with all data' do
						include_examples 'common correct files with all data'

						describe 'exe/setup.sh' do
							describe 'permissions' do
								subject(:file_permissions) do
									File.stat(File.join(Dir.pwd, app_name, 'exe/setup.sh')).mode
								end

								let(:expected_permissions) do
									File.stat("#{template}/exe/setup.sh").mode
								end

								before do
									run ## parent subject with generation
								end

								it { is_expected.to eq expected_permissions }
							end
						end
					end

					shared_examples 'correct behavior with all data' do
						include_examples 'common correct behavior with all data'
					end

					include_examples 'correct behavior with template'
				end

				context 'with `--git` option (for template)' do
					template = 'AlexWayfer/flame_app_template'

					let(:template) { template }
					let(:args) { [*super(), '--git'] }

					before do
						allow(command_instance).to receive(:`).and_call_original

						allow(command_instance).to receive(:`).with(
							a_string_starting_with("git clone -q https://github.com/#{template}.git")
						) do |command|
							target_directory = command.split.last
							FileUtils.copy_entry(
								"#{__dir__}/../support/example_template",
								## git repositories should have nested `template/`
								"#{target_directory}/template"
							)
						end
					end

					shared_examples 'correct system calls with all data' do
						include_examples 'common correct system calls with all data'
					end

					shared_examples 'correct files with all data' do
						include_examples 'common correct files with all data'
					end

					shared_examples 'correct behavior with all data' do
						include_examples 'common correct behavior with all data'
					end

					include_examples 'correct behavior with template'
				end
			end
		end
	end
end
