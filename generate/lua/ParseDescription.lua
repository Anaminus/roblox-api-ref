--[[
ParseDescription ( file )

Parses the contents of a markdown file into HTML.

The file represents user-generated data about an API item. The file is divided
into two parts: the summary, and the description. These are indicated by two
level-2 markdown headers named "Summary" and "Description" (case-insensitive).
The summary header is optional, but the description header is required in
order to separate the two.

The summary is a short and simple description placed at the top of the page.
The description is placed after auto-generated data, and may go into as much
detail as necessary.

This function returns the summary and the description, both parsed into HTML.
Returns nil if the given files does not exist, or a section is not given.

]]

return function(file)
	local function find(s,name,checks)
		for i = 1,#checks do
			local a,b = s:find(checks[i]:format(name))
			if a then
				return a,b
			end
		end
		return nil,nil
	end

	local headers = {
		-- markdown atx-style level 2 header
		'\r?\n##[ \t]*%s[ \t]*#*[ \t]*\r?\n\r?\n?';
		-- markdown atx-style level 2 header at beginning of file
		'^##[ \t]*%s[ \t]*#*[ \t]*\r?\n\r?\n?';
		-- markdown setext-style level 2 header
		'\r?\n[ \t]*%s[ \t]*\r?\n%%-+\r?\n\r?\n?';
		-- markdown setext-style level 2 header at beginning of file
		'^[ \t]*%s[ \t]*\r?\n%%-+\r?\n\r?\n?';
	}

	local source do
		local f,err = io.open(file)
		if not f then
			return nil,nil
		end
		source = f:read('*a')
		f:close()
	end

	local lower = source:lower()

	local sum_start,sum_end = 1,#source
	local desc_start,desc_end = 0,0

	local a,b = find(lower,'summary',headers)
	if a then
		sum_start = b + 1
	end

	local a,b = find(lower,'description',headers)
	if a then
		sum_end = a - 1
		desc_start = b + 1
		desc_end = #source
	end

	local sum = source:sub(sum_start,sum_end)
	local desc = source:sub(desc_start,desc_end)

	if #sum == 0 and #desc == 0 then
		return nil,nil
	end

	local markdown = require 'markdown'
	local summary = nil
	local description = nil

	if #sum > 0 then summary = markdown(sum) end
	if #desc > 0 then description = markdown(desc) end

	return summary,description
end
