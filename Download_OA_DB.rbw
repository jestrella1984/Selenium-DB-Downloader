=begin

Author: Juan Estrella
Created: 7/9/2016
Version: 1.0.0

The purpose of this program is to automate the process of downloading backup databases.

The only parameter required will be a text file named source containing a list of urls.

The program will parse through the source file containing the URLs of OpenAsset clients and 
navigate to each of the URLs, create a new backup of the clients database, then download it to
a folder located at C:\cat
	
=end


require "selenium-webdriver"
require "certified"
require "net/http"
require "set"

#Error log 
output_file = File.open('Failed_urls.log', 'w')

#This Method will validate whether or not a site is reachable before allowing any actions to be performed on it.
def working_url?(url, max_redirects=5)
  response = nil
  seen = Set.new 			#Ensures no duplicate entries
  loop do
    url = URI.parse(url)
    break if seen.include? url.to_s				#Break out of the loop is the url argument is found in the set
    break if seen.size > max_redirects			#Break out of the loop if you're redirected more than 5 times
    seen.add(url.to_s)
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = true
    response = request.request_head(url.path)
    if response.kind_of?(Net::HTTPRedirection)  #Detect a HTTP redirect
      url = response['location'] 			    #Add the new redirect location to the set if detected
    else
      break										#This means there were no redirects
    end
  end
  response.kind_of?(Net::HTTPSuccess) && url.to_s #Return true only if a URL argument was passed to the method and it was reached successfully
end

#Attempt to read in the file
begin
	input_file=File.open("source.txt","r") 
rescue
	output_file.write("Unable to open file source.txt\n")
end

data = input_file.read
url_array=data.split("\n")

#Firefox browser profile instantiation
profile = Selenium::WebDriver::Firefox::Profile.new

profile["browser.download.folderList"] = 2
profile["browser.download.dir"] = 'C:\\cat'
profile["browser.helperApps.neverAsk.saveToDisk"] = 'application/zip'

#Firefox browser object
driver = Selenium::WebDriver.for :firefox, :profile => profile
#driver.manage.window.resize_to(200,200)
wait = Selenium::WebDriver::Wait.new(:timeout => 15)
driver.manage.timeouts.implicit_wait = 20 # seconds 


url_array.each do |value|		#Cycle through all the entries

	client_url=value+'/Page/Backup'
	
	#if (a.get(client_url)) 		#Test if the url is accessible
	if (working_url?(client_url))
	
		#Loading the URL
		driver.navigate.to(client_url)

		 
		#Enter the UserName
		user_name = wait.until do
			element=driver.find_element(:id, "username")
			element if element.displayed?
		end
		user_name.send_keys "axomic"

		#Enter the Password
		password = wait.until do
			element=driver.find_element(:id, "password")
			element if element.displayed?
		end
		password.send_keys "ValThorens3200"
		 
		 
		#Clicking on the Submit Button
		submit_button = wait.until do
			element=driver.find_element(:id, "loginButton")
			element if element.displayed?
		end
		submit_button.click
		
		#Backup the datbase
		backup_db_button = wait.until do
			element=driver.find_element(:link_text, 'Backup Database Now')
			element if element.displayed?
		end
		backup_db_button.click
		
		#Download the datbase
		download_button = wait.until do
			element=driver.find_element(:class, "inlineLink")
			element if element.displayed?
		end
		download_button.click

	else
		# Print the url of the page that couldn't be loaded to an error log
		output_file.write(client_url + "\n")
	end
end
#Quitting the browser
driver.quit
output_file.close
input_file.close
