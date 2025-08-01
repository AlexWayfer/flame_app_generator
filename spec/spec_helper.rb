# frozen_string_literal: true

require 'pry-byebug'

require 'simplecov'

if ENV['CI']
	require 'coveralls'
	SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start

RSpec::Matchers.define :include_lines do |expected_lines|
	match do |actual_text|
		expected_lines.all? do |expected_line|
			actual_text.lines.any? do |actual_line|
				actual_line.strip == expected_line.strip
			end
		end
	end

	diffable
end

RSpec::Matchers.define :match_lines do |expected_matches|
	match do |actual_text|
		expected_matches.all? do |expected_match|
			actual_text.lines.any? do |actual_line|
				actual_line.match? expected_match
			end
		end
	end

	diffable
end

RSpec::Matchers.define_negated_matcher :not_ending_with, :ending_with
RSpec::Matchers.define_negated_matcher :not_include, :include
RSpec::Matchers.define_negated_matcher :not_include_lines, :include_lines
RSpec::Matchers.define_negated_matcher :not_match, :match
RSpec::Matchers.define_negated_matcher :not_output, :output

require_relative '../lib/flame_app_generator/command'
