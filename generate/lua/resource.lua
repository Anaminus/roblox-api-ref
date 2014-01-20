local utl = require 'utl'

-- Handles a list of resource files. Each item in the list is a table with the
-- following values:
-- 1: The base directory to copy the file to
-- 2: The resource type (image|css|js|favicon)
-- 3: The name of the file to copy
-- 4: An optional name to refer to the resource
-- 5: `favicon` has a 5th option specifying the favicon's sizes
-- Returns a table that is used by the resource template to include the resource files
return function(res)
	local resources = {}
	for i = 1,#res do
		local r = res[i]
		if r[2] == 'image' then
			utl.copy('resources/images/' .. r[3],r[1] .. '/img/' .. r[3],true)
		elseif r[2] == 'css' then
			utl.copy('resources/css/' .. r[3],r[1] .. '/css/' .. r[3])
			resources[r[4] or r[3]] = '<link href="/api/css/' .. r[3] .. '" rel="stylesheet" type="text/css" media="all">'
		elseif r[2] == 'js' then
			utl.copy('resources/js/' .. r[3],r[1] .. '/js/' .. r[3])
			resources[r[4] or r[3]] = '<script type="text/javascript" src="/api/js/' .. r[3] .. '"></script>'
		elseif r[2] == 'favicon' then
			utl.copy('resources/images/' .. r[3],r[1] .. '/img/' .. r[3],true)
			resources[r[4] or r[3]] = '<link rel="icon" sizes="' .. r[5] .. '" href="/api/img/' .. r[3] .. '">'
		end
	end
	return resources
end
