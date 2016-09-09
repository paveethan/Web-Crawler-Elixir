#Assignment3.ex
defmodule Assignment3 do
 
def startOn(webUrl, maxPages \\ 10, maxDepth \\ 3) do
validUrl = checkValidHtml(webUrl)
maximumPages = checkValidMaxPages(maxPages)
maximmumDepth = checkValidMaxDepth(maxDepth)
if validUrl do
	visitedURLs = %{}
	counter = 1
	urlToVisit = [webUrl]
	globalTagCounter =  %{}
	startCrawl(urlToVisit, visitedURLs, globalTagCounter, maximumPages )
end
end

defp startCrawl(urlToVisit, visitedURLs, globalTagCounter, 0) do
	"Finished"
end

defp startCrawl(urlToVisit, visitedURLs, globalTagCounter, maximumPages) do
	IO.puts "Global Tag Counter: "
	IO.inspect globalTagCounter
	IO.inspect urlToVisit
	webUrl = hd(urlToVisit)
	IO.inspect visitedURLs
	checkIfVisited = Map.get(visitedURLs, webUrl, "0")
	boolCheck = String.equivalent?("0",checkIfVisited)
	IO.puts boolCheck
	if boolCheck do
		IO.puts "Link: " <> webUrl
		visitedURLs = Map.put(visitedURLs, webUrl, 1)
		urlToVisit = crawlLinks(webUrl,urlToVisit)
		localTagCounter = crawlTags(webUrl,globalTagCounter)
		globalTagCounter = addToGlobal(localTagCounter,globalTagCounter)
	end
	startCrawl(tl(urlToVisit), visitedURLs, globalTagCounter, maximumPages - 1) 
end

defp crawlTags(webUrl,globalTagCounter) do
	IO.puts "TagCrawler PID"
	{:ok, tagParserPID} = TagParser.start_link
	IO.inspect tagParserPID
	send tagParserPID, {:put, webUrl}
	send tagParserPID, {:get, self()}
	returnTagList = {}
	receive do
		msg -> returnTagList = msg
	end
	IO.puts "Tags found: "
	IO.inspect returnTagList
	returnTagList
end

defp addToGlobal([],globalTagCounter)do
	IO.inspect globalTagCounter
	globalTagCounter
end

defp addToGlobal(returnTagList,globalTagCounter)do
	temp = Tuple.to_list(hd(returnTagList))
	[tempKey, tempValue] = temp
	checkIfExists = Map.get(globalTagCounter, tempKey, "0")
	tempString = to_string(checkIfExists)
	checkIfValueExists = String.equivalent?("0",tempString)
	if checkIfValueExists do
		globalTagCounter = Map.put_new(globalTagCounter,tempKey,1)
	else
		value = Map.fetch(globalTagCounter, tempKey)
		{:ok, trueValue} = value
		globalTagCounter = Map.put(globalTagCounter,tempKey,trueValue + 1)
	end
	addToGlobal(tl(returnTagList),globalTagCounter)
end

defp crawlLinks(webUrl,urlToVisit) do
	IO.puts "url parser id: "
	{:ok, urlParserID} = URLParser.start_link
	IO.inspect urlParserID
	send urlParserID, {:put, webUrl}
	send urlParserID, {:get, self()}
	returnHTMLList = {}
	receive do
		msg -> returnHTMLList = msg
	end
	IO.puts "HTTP links found: "
	IO.inspect returnHTMLList
	IO.puts ""
	urlToVisit = urlToVisit ++ returnHTMLList
	IO.puts "crawling links: "
	IO.inspect urlToVisit
	urlToVisit
end

defp checkValidHtml(url) do
	String.starts_with? (quote do unquote(url) end), "http"
end

defp checkValidMaxPages(maxPages) do
temp = Macro.to_string(quote do: unquote(maxPages))
list = String.split(temp, [" ","]"])
newList = List.delete_at(list,0)
finalList = List.delete_at(newList,1)
bloop = List.to_string(finalList)
finalValue = Integer.parse(quote do: unquote(bloop))
elem(finalValue,0)
end

defp checkValidMaxDepth(maxDepth) do
temp = Macro.to_string(quote do: unquote(maxDepth))
list = String.split(temp, [" ","]"])
bloop = List.to_string(list)
finalValue = Integer.parse(quote do: unquote(bloop))
elem(finalValue,0)
end

end