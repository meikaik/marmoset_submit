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

	option :release do
		short   '-r'
		long    '--release'
		desc    'Flag to release test a specific question'
		default false
	end

	option :help do
		short   '-t'
		long '--help'
		desc 'Help page'
	end
end
