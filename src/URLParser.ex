defmodule URLParser do

def start_link do
Task.start_link(fn -> start([]) end)
end

defp start(newTagList) do 
	receive do 
	{:get, caller} -> 
		send caller,newTagList
	{:put, validUrl} -> 
		start(actualStart(validUrl))
	end
end

defp actualStart(validUrl) do
		HTTPoison.start
		list = HTTPoison.get(validUrl)
		{:ok, subList} = list
		tempValue = Map.fetch(subList, :body)
		newList = Tuple.to_list(tempValue)
		newList2 = List.delete(newList,:ok)
		newString = List.to_string(newList2)
		newList3 = String.split(newString, "\n")
		tempList = []
		index = 0
		newHtmlList = getHtmlTags(newList3, tempList, index)
		newHtmlList
end

defp getHtmlTags([], tempList, index) do
	tempList
end

defp getHtmlTags(newList3, tempList, index) do
	temp = insideList(hd(newList3))
	checkNull = String.equivalent?("null",temp)
	if checkNull do
	else
		tempList = List.insert_at(tempList,index,temp)
		index = index + 1
	end
	getHtmlTags(tl(newList3), tempList, index) 
end



defp insideList(x) do
	check = String.contains?(x, "<a ")
	insidetemp = case check do
		true ->  check2Stuff(x)
		false ->  "null"
	end

end

defp check2Stuff(x) do
	check2 = String.contains?(x, "href=\"http")
	checktemp = case check2 do
		true -> insideCheckStuff(x)
		false -> "null"
	end
end

defp insideCheckStuff(x) do
		linkFound = keepHtmlTags(x)
end


defp keepHtmlTags(x) do
	actualLen = String.length(x)
	[{start, len}] = Regex.run(~r/href=\"/, x, return: :index)
	newLink = String.slice(x,start+len,actualLen)

	newActualLen = String.length(newLink)
	[{start2, len2}] = Regex.run(~r/\"/, newLink, return: :index)
	newerLink = String.slice(newLink,0,start2)
end
end