# OA

This program automates web tasks in openasset. It parses through a file containing a list of web addresses. The program then 
goes to each address, logs in, creates a backup of the database, then downloads it to the C:\cat directory which is automatically 
created. Any sites that are unreachable are logged in the Failed_URLS.log file which is created in the same directory that the program
runs in. To run the program simply double click it. You must have ruby 2.2.4 or greater installed. The following ruby gems are also required: certified, selenium-webdriver. To install a gem after the ruby interpreter is on your machine just type the followin in the windows command prompt: gem install <gem name>

