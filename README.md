# Flame App Generator

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/flame_app_generator?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/flame_app_generator)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/flame_app_generator/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/flame_app_generator)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/flame_app_generator.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/flame_app_generator)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/flame_app_generator?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/flame_app_generator)
[![license](https://img.shields.io/github/license/AlexWayfer/flame_app_generator.svg?style=flat-square)](LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/flame_app_generator.svg?style=flat-square)](https://rubygems.org/gems/flame_app_generator)

Gem for new [Flame](https://github.com/AlexWayfer/flame) web applications generation.

It was created for myself, but you can suggest options for generation to adopt it for your usage.

## Installation

Install it globally:

```shell
gem install flame_app_generator
```

## Usage

### With local template

```sh
flame_app_generator name_of_a_new_app path/to/template
```

### With GitHub template

```sh
flame_app_generator name_of_a_new_app template_github_org/template_github_repo --git
```

Be aware: `flame_app_generator` uses `template/` directory from the GitHub repo, not the root one.

### With custom project name

It can be used instead of camelized app name, for example:

```sh
flame_app_generator foobar path/to/template --project-name=FooBar
```

### With custom domain

It can be used instead of default `.com` domain, for example:

```sh
flame_app_generator foobar path/to/template --domain=foo-bar.dev
```

## Template creation

Example of gem template you can see at [AlexWayfer/flame_app_template](https://github.com/AlexWayfer/flame_app_template).

Available paths:

| Path part  | Example of source | Example of result |
| ---------- | ----------------- | ----------------- |
| `app_name` | `app_name.rb`     | `foo_bar.rb`      |

Any `*.erb` file will be rendered via [ERB](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html);
if you want an `*.erb` file as result — name it as `*.erb.erb` (even if there are no tags).

Available variables:

| Variable            | Example of result  | Default                         |
| ------------------- | ------------------ | ------------------------------- |
| `name`, `app_name`  | `foo_bar`          | _required_                      |
| `module_name`       | `FooBar`           | camelized app name              |
| `short_module_name` | `FB`               | upcased chars from module name  |
| `domain_name`       | `foobar.com`       | downcased module name + `.com`  |
| `indentation`       | `tabs` or `spaces` | `tabs` (it's easier to convert) |

By default indentation is `tabs`, but if a template spaces-indented — option will not affect.
So, this option only for tabs-indented templates.

### Git templates

You can create public git-templates and then guide users to call
`flame_app_generator app_name your_org/your_repo --git`,
but be aware that `flame_app_generator` will look for template inside `template/` directory
to allow you having out-of-template README, specs (for the template itself), anything else.

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome
on [GitHub](https://github.com/AlexWayfer/flame_app_generator).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
