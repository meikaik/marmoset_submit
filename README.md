# Welcome to Marmoset Submit
Marmoset_submit is a command-line tool which allows you to submit files to the the University of Waterloo Marmoset testing server.

### Features:
* Submission of any file to any question on Marmoset
* Release test your submissions
* Public test results are displayed after file submission
* Public/Release test errors are printed to stdout
* Enquire about release tokens and regeneration time
* **COMING SOON:** View scores for all subquestions
* **COMING SOON:** View all release tokens available for all parts of a question
* **COMING SOON:** Schedule release tests to run automatically  12 hours after you run out of tokens
* **COMING SOON:** Batch upload

### Usage
* `gem install marmoset_submit`
* This command submits FILENAME to QUESTION:
```
marmoset_submit -u QUESTID -p PASSWORD -c COURSEID -q QUESTION -f FILENAME
```
* This command release tests QUESTION: 
```
marmoset_submit -r -u QUESTID -p PASSWORD -c COURSEID -q QUESTION
```
* If `marmoset_submit` is run, the program will prompt the user for input

### Flags
* `-h` - help
* `-u` - your quest username (ie mkkoh)
* `-p` - your quest password
* `-c` - your course ID (ie cs241)
* `-f` - the filename you would like to submit
* `-q` - the question you are submitting to 
* `-r` - used for release testing
* `-t` - allows user to specify submission time when there are no release tokens available

### Misc
* To prevent marmoset_submit from prompting you to type your username and password:
```
echo 'export UWID=yourusername' >> ~/.bash_profile
echo 'export UWPASS=yourpassword' >> ~/.bash_profile
```
