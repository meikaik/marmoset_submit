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
		short   '-q'
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
