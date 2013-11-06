--[[
ParseDescription ( file )

Retrieves descriptions for a class from a given markdown dile.

The file is divided into sections, delimited by level-1 headers. The following
header names are detected (case-insensitive):

- summary: A short and simple description of the class.
- details: A long description of the class.
- members: Descriptions of each member.

The members section is further divided into subsections; one for each member
of the class. Each subsection is delimited by a level-2 header, with the name
of the member as the header name (case-sensitive).

Returns a table with the following fields:

- `summary`: The content of the summary section, parsed into HTML.
- `details`: The content of the details section, parsed into HTML.
- `members`: A set of member names paired with their corresponsing section
  content, parsed into HTML.

The order of sections does not matter.

All sections and subsections are optional. If a section is omitted, its
returned value will simply be nil. Note that sections that are empty may not
be detected.

]]

-- find a header and return it's start and end position, and its level and name
local function findHeader(source,init)
	-- find atx-style header at beginning
	-- this could probably be better
	local a,b = source:find('^#+[ \t]*[^\n][^\n]-[ \t]*#*[ \t]*\n',init)
	if not a then
		-- find on a new line instead
		a,b = source:find('\n#+[ \t]*[^\n][^\n]-[ \t]*#*[ \t]*\n',init)
	end

	-- find setext-style header
	local c,d = source:find('^[ \t]*([^\n][^\n]-)[ \t]*\n[-=]+\n',init)
	if not c then
		c,d = source:find('\n[ \t]*[^\n][^\n]-[ \t]*\n[-=]+\n',init)
	end

	-- both may have matched, so select the first
	if a and c then
		if c < a then
			a = nil
		else
			c = nil
		end
	end

	-- extract the level and name out of the matched header
	if a then
		local level,name = source:sub(a,b):match('(#+)[ \t]*([^\n][^\n]-)[ \t]*#*[ \t]*\n')
		return a,b,#level,name
	elseif c then
		local name,level = source:sub(c,d):match('[ \t]*([^\n][^\n]-)[ \t]*\n([-=]+)\n')
		-- make sure each character matches
		if level:match('^=+$') then
			-- level 1 header
			return c,d,1,name
		elseif level:match('^-+$') then
			-- level 2 header
			return c,d,2,name
		end
	end

	return nil
end

-- trim leading and trailing whitespace
local function trim(s)
	return s:gsub('^%s+',''):gsub('%s+$','')
end

return function(file)
	local source do
		local f,err = io.open(file)
		if not f then
			return {}
		end
		source = f:read('*a')
		f:close()
	end

	-- convert DOS and Mac newlines to UNIX, for convenience
	-- markdown parser already does it anyway
	source = source:gsub('\r\n','\n'):gsub('\r','\n')

	-- find sections, delimited by headers
	local sections = {}
	local low = source:lower()
	local secName
	local secStart,secEnd
	local init = 0
	while true do
		-- header names are case-insensitive
		local headStart,headEnd,level,name = findHeader(low,init + 1)
		if not headStart then
			break
		end

		-- only find level 1 headers; skip over other ones
		if level == 1 then
			if secName then
				secEnd = headStart - 1
				sections[secName] = source:sub(secStart,secEnd)
			end
			secName = name
			secStart = headEnd + 1
		end
		init = headEnd
	end
	if secName then
		sections[secName] = source:sub(secStart,#source)
	end

	-- extract the sections we want and convert them to HTML
	local markdown = require 'markdown'
	local descriptions = {}

	local summary = trim(markdown(sections.summary or ''))
	if #summary > 0 then
		descriptions.summary = summary
	end

	local details = trim(markdown(sections.details or ''))
	if #details > 0 then
		descriptions.details = details
	end

	-- parse out the sub-sections of the member section
	local memberSection = sections.members
	if memberSection and #memberSection > 0 then
		local members = {}

		local memberName
		local memberStart,memberEnd
		local init = 0
		while true do
			local headStart,headEnd,level,name = findHeader(memberSection,init + 1)
			if not headStart then
				break
			end

			if level == 2 then
				if memberName then
					memberEnd = headStart - 1
					local content = trim(markdown(memberSection:sub(memberStart,memberEnd)))
					if #content > 0 then
						members[memberName] = content
					end
				end
				memberName = name
				memberStart = headEnd + 1
			end
			init = headEnd
		end
		if memberName then
			local content = trim(markdown(memberSection:sub(memberStart,#memberSection)))
			if #content > 0 then
				members[memberName] = content
			end
		end

		descriptions.members = members
	end

	return descriptions
end
