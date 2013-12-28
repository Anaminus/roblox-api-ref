--[[

ParseVersionList ( filename )

Parses a file containing a list of version hashes. Each line in the file
should have the following format:

version-<hash>	<year>-<month>-<day>	<type>

- <hash>    A sequence of hexidecimal characters
- <year>    A 4-digit number indicating the year
- <month>   A 2-digit number indicating the month
- <day>     A 2-digit number indicating the day
- <type>    Either "Player" or "Studio", indicating the build type

Returns a list of versions, sorted by date (newest to oldest). Each entry is a
table with the following values:
- The date, as an integer
- The player version
- The studio version

]]

local utl = require 'utl'
return function (versions)
	local data = utl.read(versions)
	local dates = {}
	for line in data:gmatch('[^\r\n]+') do
		local ver,y,m,d,type = line:match('^(version%-%x+)\t(%d%d%d%d)%-(%d%d)%-(%d%d)\t(%w+)$')
		if ver then
			type = type:lower()
			if type == 'player' or type == 'studio' then
				local date = os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d)})
				if not dates[date] then
					dates[date] = {date,nil,nil}
				end
				dates[date][type == 'studio' and 3 or 2] = ver
			end
		end
	end
	local list = {}
	for _,item in pairs(dates) do
		list[#list+1] = item
	end
	table.sort(list,function(a,b)
		return a[1] > b[1]
	end)

	-- if a version type is missing for a given date, use the latest that was
	-- available before it
	local lastPlayer = nil
	local lastStudio = nil
	for i = #list,1,-1 do
		if list[i][2] then
			lastPlayer = list[i][2]
		else
			list[i][2] = lastPlayer
		end
		if list[i][3] then
			lastStudio = list[i][3]
		else
			list[i][3] = lastStudio
		end
	end

	return list
end
