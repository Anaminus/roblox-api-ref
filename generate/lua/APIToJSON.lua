local API = require 'API'

-- Converts API dump table to JSON format that will be handled by fuzzy search.
-- Returns an array of objects, each containing the following fields:

-- c: Class name;
-- m: Member name; not defined if object represents a class
-- i: Icon index; icon of class or member

-- `dump` is the API dump as converted by LexAPI.lua
-- If `raw` is true, the unjoined string array is returned
return function(dump,raw)
	local contentString = {}
	local function output(...)
		local args = {...}
		for i = 1,#args do
			contentString[#contentString+1] = tostring(args[i])
		end
	end

	local function handleItem(item,first)
		if item.type == 'Class' then
			output(
				first and '' or ',',
				'{',
					'"c":"',item.Name,'",',
					'"i":',API.ClassIconIndex(item.Name),
				'}'
			)
			return true
		elseif item.type == 'Property'
		or item.type == 'Function'
		or item.type == 'YieldFunction'
		or item.type == 'Event'
		or item.type == 'Callback' then
			output(
				first and '' or ',',
				'{',
					'"c":"',item.Class,'",',
					'"m":"',item.Name,'",',
					'"i":',API.MemberIconIndex(item),
				'}'
			)
			return true
		end
	end

	output('[')
	if #dump > 0 then
		local first = true
		for i = 1,#dump do
			if handleItem(dump[i],first) then
				first = false
			end
		end
	end
	output(']')

	if raw then
		return contentString
	else
		return table.concat(contentString)
	end
end
