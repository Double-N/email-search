require 'mechanize'
require 'nokogiri'
require 'csv'

file = CSV.read("GPU Accelerated Applications - Sheet1.csv")
matrix_all = file.to_a()

array_companies = Array.new
for index in 3..matrix_all.length
	if matrix_all[index] != nil and matrix_all[index][1] != nil
		if matrix_all[index][1] != matrix_all[index][1].upcase()   #<<<<<<this is case specific
			array_companies = matrix_all[index][1]
		end
	end
end

for index in 0..array_companies.length
	unless array_companies[index] == nil or array_companies[index] == ""
		array_companies[index][0] = '' if array_companies[index][0] = " "
		for i in 0..array_companies[index].length	
			if array_companies[index][i] == "["
				array_companies[index][i..(array_companies[index].length)] = ''
				break
			end
		end
	else
		array_companies.delete(array_companies[index].to_s)  #not deleting?????????&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		index -= 1
	end
end


$agent = Mechanize.new
$agent.user_agent_alias = 'Linux Firefox'
page = $agent.get('http://google.com')
search_form = page.form_with(:name => "f")

emails_file = File.open("emails", "w")
for index in 0..array_companies.length
	puts "searching for @ " + array_companies[index]
	search_form.field_with(:name => "q").value = array_companies[index]
	results_page = $agent.submit(search_form)
	results = results_page.search(".g")[0..10]
	page_text = ""
	for r in 0..results.length
		url = results[i].search(".r a")[0]['href'].to_s
		url[0..6] = ''
		begin
	    	page = Nokogiri::HTML(open(url).read)
		rescue
		    puts "a url was unreadable"
		end
		page.search('script').each {|el| el.unlink}
		page_text += page.text
	end
	page_text.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '*') #will replace bad character with *, email is bad with this
	emails = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.match page_text
	emails_file.puts array_companies[index] + " emails: "
	for e in 0..emails.length
		emails_file.puts "\t" + emails[e] unless emails_file.include? emails[e]
	end
	emails_file.puts "\n"
end

puts "Emails compiled."
