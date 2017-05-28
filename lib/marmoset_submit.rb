require 'io/console'
require 'rubygems'
require 'mechanize'
require 'highline'
require 'choice'
require 'nokogiri'

class Marmoset
  class InvalidLogin < StandardError; end
  class CourseNotFound < StandardError; end
  class QuestionNotFound < StandardError; end

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
      @username = gets.chomp
    end
    if @password == nil
      print 'Password: '
      #@password = STDIN.noecho(&:gets).chomp
      @password = gets.chomp
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
      @course = gets.chomp
    end

    @course = @course.upcase

    course_link = course_links.find do |link|
      link.text.include? @course
    end

    @course_page = course_link.click

    puts "Selecting #{@course}..."

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
      @question = gets.chomp
    end

    puts "Selecting #{@question}..."

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
      @filename = gets.chomp
    end

    puts "Submitting #{@question}..."

    form = @submission_page.forms.first
    form.file_uploads.first.file_name = @filename
    @agent.submit(form)

    puts "Congratulations, #{@question} has been successfully uploaded to Marmoset."

  rescue Mechanize::ResponseCodeError
    puts "File #{@question} submission failed. Please try again!"
    exit
  end

  def public_test
    question_overview = @base_url + @question_overview_hash[@question].href
    @agent.get question_overview
    html = Nokogiri::HTML(@agent.page.content)
    asd = html.xpath('/html/body/table/tbody/tr[2]/td[3]')
    puts asd
  end

  def token_overview

  end

  def tokens(question)

  end

end

Choice.options do
  option :username do
    short   '-u'
    long    '--username=USERNAME'
    desc    'Your Quest userid (eg mkkoh)'
    default nil
  end

  option :password do
    short   '-p'
    long    '--password=PASSWORD'
    desc    'Your Quest password.'
    default nil
  end

  option :course do
    short   '-c'
    long    '--course=COURSE'
    desc    'Course ID (eg CS241)'
    default nil
  end

  option :filename do
    short   '-f'
    long    '--filename=FILENAME'
    desc    'The file to submit to marmoset'
  end

  option :question do
    short   '-a'
    long    '--question=QUESTION'
    desc    'Marmoset submission question name (eg A3P2 or A3Q2)'
    default nil
  end

  option :submissiontime do
    short   '-t'
    long    '--submissiontime=SUBMISSIONTIME'
    desc    'Marmoset submission time in 24hr format (eg 06/01/2017 21:00)'
    default nil
  end

  option :help do
    short   '-t'
    long '--help'
    desc 'All arguments are required except for -t / --submissiontime. Use -t ' \
         'if you would like to submit your assignment at a particular time.'
  end
end

client = Marmoset.new(Choice.choices)
client.login
client.select_course
client.select_question
client.submit_question
client.public_test