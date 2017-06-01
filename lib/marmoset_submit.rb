require 'mechanize'
require 'commander'
require 'choice'

require_relative 'marmoset'
require_relative 'cli_options'

browser = Marmoset.new(Choice.choices)
browser.login
browser.select_course
browser.select_question
if Choice[:release]
  # after verifying public test score, view_public_test calls release_test
  browser.view_public_test
else
  browser.submit_question
  browser.view_public_test
end
