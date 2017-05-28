Gem::Specification.new do |s|
  s.name         = 'marmoset_submit'
  s.version      = '0.0.1'
  s.date         = '2017-06-01'
  s.summary      = 'Command line submission to the Marmoset Testing Server'
  s.description  = 'Submit to the University of Waterloo Marmoset Testing Server via command line'
  s.authors      = ['Mei Kai Koh']
  s.email        = 'mkkoh@uwaterloo.ca'
  s.homepage     = 'http://rubygems.org/gems/marmoset_submit'
  s.license      = 'MIT'
  s.files        = ['lib/marmoset_submit.rb']

  s.add_runtime_dependency 'mechanize', ['>= 2.7.5']
  s.add_development_dependency 'mechanize', ['>= 2.7.5']
  s.add_runtime_dependency 'highline', ['>= 1.7.8']
  s.add_development_dependency 'highline', ['>= 1.7.8']
  s.add_runtime_dependency 'choice', ['>= 0.2.0']
  s.add_development_dependency 'choice', ['>= 0.2.0']
end