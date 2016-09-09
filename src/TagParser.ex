defmodule TagParser do

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
		map = %{"<!DOCTYPE html>" => 1}
		tagList = Regex.scan(~r/<[a-z|A-Z]+[0-9]*/, newString)
		newTagList = Map.to_list(getMapStuff(tagList, map))
		newTagList
end

defp getMapStuff([], map) do
	map	
end

defp getMapStuff(tagList, map) do
	mapInput = List.to_string(hd(tagList))
	mapInput = mapInput <> ">"
	checkIfExists = Map.get(map, mapInput, "0")
	tempString = to_string(checkIfExists)
	checkIfValueExists = String.equivalent?("0",tempString)
	if checkIfValueExists do
		map = Map.put_new(map,mapInput,1)
	else
		value = Map.fetch(map, mapInput)
		{:ok, trueValue} = value
		map = Map.put(map,mapInput,trueValue + 1)
	end
	getMapStuff(tl(tagList), map)
end
end