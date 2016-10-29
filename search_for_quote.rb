require mechanize
require nokogiri


def get_page_summary(url)
	page = agent.get(url)
	puts "This should be body stuff: " + page.search('p').map{|p| p.content}
	return page.search('p').map{|p| p.content}
end

def look_for_quote(stuff, quote)
	if stuff.include? quote
		return quote
	else
		return "None"
end

def find_results(quotes)
	agent = Mechanize.new
	agent.user_agent_alias = 'Linux Firefox'
	page = agent.get('http://google.com')
	search_form = page.form_with(:name => "f")
	j = 0
	while j < quotes.length
		k = 0
		while k < quotes.length
			search_form.feild_with(:name => "q").value = quotes[k]  #quote = "Global Valuation Esther supports OpenCL"  ~~~
			results_page = agent.submit(search_form)
			results = results_page.search(".g")[0..10]

			i = 0
			all = ""
			while i < results.length do
				url = results[i].search(".r a")[0]['href'])
				final = look_for_quote(get_page_summary(url, quotes[j]))
				if final != "None" && not all.include? url
					all += quote + " -found at- " + url + "\n\n"
					#system("start #{url}")
				i+=1
			end
			k+=1
		end
		j+=1
	end
	return all
end

quotes_file = File.open("quotes.txt", "r")
contents = quotes_file.read
quotes_file.close
quotes1 = contents.split('|')
result_for_file = find_results(quotes1)
result_file = File.open("result.txt", "w")
result_file.puts result_for_file
result_file.close
puts "Done"

