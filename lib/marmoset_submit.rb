require 'io/console'
require 'rubygems'
require 'mechanize'
require 'highline'
require 'choice'
require 'nokogiri'
require_relative 'cli_options'

class MarmosetSubmit
  class InvalidLogin < StandardError; end
  class CourseNotFound < StandardError; end
  class QuestionNotFound < StandardError; end
  class NoReleaseTokens < StandardError; end

  def initialize(args)
    @agent                  = Mechanize.new
    @base_url               = 'https://marmoset.student.cs.uwaterloo.ca'

    # Used for navigating between functions
    @course_page            = nil
    @submission_page        = nil
    @question_submit_hash   = {}
    @question_overview_hash = {}

    # user-specified arguments
    @username               = args[:username]
    @password               = args[:password]
    @course                 = args[:course]
    @filename               = args[:filename]
    @question               = args[:question]
    @submissiontime         = args[:submissiontime]
  end

  def login
    if @username == nil
      print 'Username: '
      @username = STDIN.gets.chomp
    end
    if @password == nil
      print 'Password: '
      #@password = STDIN.noecho(&:gets).chomp
      @password = STDIN.gets.chomp
    end

    puts "Logging in as user #{@username}"

    login_page = @agent.get @base_url
    form = login_page.forms.first

    form.username = @username
    form.password = @password

    login_submit_page = @agent.submit form

    if login_submit_page.uri.to_s.include? 'cas.uwaterloo.ca'
      raise InvalidLogin
    end

    @course_index_page = @agent.submit login_submit_page.forms.first
  rescue InvalidLogin
    puts 'Invalid Username/Password.'
    exit
  end

  def select_course

    course_links = @course_index_page.links.find_all do |link|
      link.href.include? 'course.jsp'
    end

    if @course.nil?
      puts 'Here are your courses :'
      course_links.each do |course_link|
        puts course_link.text.strip.chomp ':'
      end
      puts 'Please enter the Course ID you would like to submit your assignment to (eg CS241):'
      @course = STDIN.gets.chomp
    end

    @course = @course.upcase

    course_link = course_links.find do |link|
      link.text.include? @course
    end

    @course_page = course_link.click

    unless @agent.page.title == "#{@course} Submit Server"
      raise CourseNotFound
    end

  rescue CourseNotFound
    puts "Course #{@course} not found. Here are the courses you are enrolled in:"
    course_links.each do |course_link|
      puts course_link.text.strip.chomp ':'
    end
    exit
  end

  def select_question
    if @question == nil
      print 'Question (eg A3P2): '
      @question = STDIN.gets.chomp
    end

    @question = @question.upcase

    # question_submit_hash['A3P2'] => #<Mechanize::Page::Link "path-to-submission-link">
    questions_stripped        = @course_page.links.find_all{|question| question.text.gsub!(/[^0-9A-Za-z]/, '')}
    question_submission_links = @course_page.links.find_all{|link| link.href.include? 'submitProject.jsp'}
    question_overview_links   = @course_page.links.find_all {|link| link.text.include? 'view'}
    questions_text            = questions_stripped.map {|question| question.text}
    filtered_questions        = questions_text.select { |val| val.match /^[aA][0-9]/ }
    upcased_questions         = filtered_questions.map {|question| question.upcase}
    @question_overview_hash   = Hash[upcased_questions.zip question_overview_links]
    @question_submit_hash     = Hash[upcased_questions.zip question_submission_links]

    raise QuestionNotFound if @question_submit_hash[@question] == nil

    @submission_page = @question_submit_hash[@question].click

  rescue QuestionNotFound
    puts "Question #{@question} not found. Here are the questions available:"
    puts filtered_questions.join(', ')
    exit
  end

  def submit_question

    if @filename.nil?
      print 'Filename: '
      @filename = STDIN.gets.chomp
    end

    puts "Submitting #{@question}..."

    form = @submission_page.forms.first
    form.file_uploads.first.file_name = @filename
    @agent.submit(form)

    puts "#{@question} has been successfully uploaded to Marmoset."

  rescue Mechanize::ResponseCodeError
    puts "File #{@question} submission failed. Please try again!"
    exit
  end

  def view_public_test
    question_overview = @base_url + @question_overview_hash[@question].href
    public_test_score = 'nottestedyet'
    while public_test_score == 'nottestedyet'
      @agent.get question_overview
      html = Nokogiri::XML @agent.page.body
      public_test_score = html.xpath('//tr[1]/td[3]').text.gsub!(/[^0-9A-Za-z\/]/, '')
      sleep 3
    end

    if public_test_score == 'didnotcompile'
        puts "#{@question} did not compile on the UW student environment."
    else # there is a score for the public test
      puts "Your public test score for #{@question} is #{public_test_score}"
      score_array = public_test_score.split'/'
      if score_array[0] != score_array[1]
        print_long_error
      else
        release_test
      end
    end
  end

  def print_long_error
    question_overview = @base_url + @question_overview_hash[@question].href
    @agent.get question_overview
    view_links = @agent.page.links.find_all{|link| link.text.include? 'view'}
    view_links.first.click
    html = Nokogiri::XML @agent.page.body
    error = html.xpath('//tr[2]/td[7]/span').text.gsub!(/[^0-9A-Za-z\/ ]/, '')
    puts 'Error: ', error
  end

  def release_test
    question_stats = get_question_stats
    puts "Would you like to release test this submission?",
         "You have #{question_stats['release_tokens']} tokens left (Y/N)"
    answer = STDIN.gets.chomp
    exit if answer.upcase = 'N'
    raise NoReleaseTokens if question_stats['release_tokens'] == 0

  rescue NoReleaseTokens
    puts "Sorry, you have 0 release tokens for #{@question}. Your tokens will regenerate in:"
    puts question_stats['release_token_regeneration']
  end

  def token_overview

  end

  # returns Hash{
  #              public_test:
  #              release_test:
  #              release_tokens:
  #              release_token_regeneration: []
  # }
  def get_question_stats
    question_stats = {}
    question_overview = @base_url + @question_overview_hash[@question].href
    @agent.get question_overview
    view_links = @agent.page.links.find_all{|link| link.text.include? 'view'}
    submission_page = view_links.first.click
    html = submission_page.body
    html_nokogiri = Nokogiri::HTML submission_page.body

    # regexp match to pull scores
    public_test_score          = html[/[0-9]\/[0-9]\s*points for public test cases./]
    release_test_score         = html[/[0-9]\/[0-9]\s*points for release tests./]
    release_tokens             = html[/[0-9]\s*release\s*tokens\s*/]
    release_token_regeneration = html_nokogiri.xpath('//ul').text.gsub!(/[^0-9A-Za-z ]/, '')

    question_stats['public_test']                = public_test_score[/[0-9]\/[0-9]/] if public_test_score
    question_stats['release_test']               = release_test_score[/[0-9]\/[0-9]/] if release_test_score
    question_stats['release_tokens']             = release_tokens[/[0-9]/] if release_tokens
    question_stats['release_token_regeneration'] = release_token_regeneration

    return question_stats
  end


  def tokens(question)

  end

end

client = MarmosetSubmit.new(Choice.choices)
client.login
client.select_course
client.select_question
#client.submit_question
client.view_public_test