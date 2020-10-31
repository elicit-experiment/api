# frozen_string_literal: true

# https://stackoverflow.com/questions/5654517/in-ruby-on-rails-to-extend-the-string-class-where-should-the-code-be-put-in

Dir[File.join(Rails.root, 'lib', 'core_ext', '*.rb')].each { |l| require l }
