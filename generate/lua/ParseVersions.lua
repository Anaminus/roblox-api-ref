local schema = {}

--[[ Version 1

returns BuildList

type BuildList struct {
	Schema int     // The version of this schema
	Domain string  // The URI domain where builds may be downloaded
	List   []Build // A list of player build info
}

type Build struct {
	Date          int
	PlayerHash    string
	StudioHash    string
	PlayerVersion string
}

]]
schema[1] = function(content,i)
	local s,f,domain = content:find('^(.-)\n',i)
	if not domain then
		return nil,"invalid domain"
	end

	local list = {}
	local versions = {
		Schema = 1;
		Domain = domain;
		List = list;
	}

	local first = true
	for line in content:sub(f+1):gmatch('[^\n]+') do
		if first then
			first = false
			local fields = {line:match('^(.+)\t(.+)\t(.+)\t(.+)$')}
			if fields[1] ~= 'Date'
			or fields[2] ~= 'PlayerHash'
			or fields[3] ~= 'StudioHash'
			or fields[4] ~= 'PlayerVersion' then
				return nil,"invalid field name"
			end
		else
			local date,phash,shash,pver = line:match('^(%d+)\t(version%-%x+)\t(version%-%x+)\t(%d+%.%d+%.%d+%.%d+)$')
			date = tonumber(date)
			if date then
				list[#list+1] = {
					Date = date;
					PlayerHash = phash;
					StudioHash = shash;
					PlayerVersion = pver;
				}
			end
		end
	end

	return versions
end

return function(content)
	if not content then
		return nil,"argument must be a string"
	end

	local s,f,v = content:find('^schema (%d+)\n')
	v = tonumber(v)
	if not v then
		return nil,"malformed schema version"
	end
	if not schema[v] then
		return nil,"schema version " .. v .. " is not supported"
	end

	return schema[v](content,f+1)
end
