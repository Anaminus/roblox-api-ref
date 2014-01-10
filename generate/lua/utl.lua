-- Contains utility operations.

local lfs = require 'lfs'
local format = require 'format'

local utl = {}

-- Combines arguments into a path, and normalizes
function utl.path(...)
	local a = {...}
	local p = a[1] or ''
	for i = 2,#a do
		p = p .. '/' .. a[i]
	end
	return p:gsub('[\\/]+','/')
end

-- recursively clears a directory of all its contents
function utl.cleardir(dir)
	local function r(d)
		for f in lfs.dir(d) do
			if f ~= '.' and f ~= '..' then
				f = d .. '/' .. f
				if lfs.attributes(f,'mode') == 'directory' then
					r(f)
					lfs.rmdir(d)
				else
					os.remove(f)
				end
			end
		end
	end
	r(dir)
end

-- creates a directory, also creating parent directories, if necessary
function utl.makedir(dir)
	local d = ''
	for f in dir:gmatch('[^/]+') do
		d = d .. f .. '/'
		lfs.mkdir(d)
	end
end

-- copies one file to another
function utl.copy(an,bn,bin)
	local a = io.open(an,'r' .. (bin and 'b' or ''))
	local b = io.open(bn,'w' .. (bin and 'b' or ''))
	b:write(a:read('*a'))
	b:flush()
	a:close()
	b:close()
end

-- read content from a file in one go.
function utl.read(file,bin)
	local f,err = io.open(file,'r' .. (bin and 'b' or ''))
	if not f then
		return nil,err
	end
	local content = f:read('*a')
	f:close()
	return content
end

-- Writes content to a file in one go. Content may be a table.
function utl.write(file,content,bin)
	local f,err = io.open(file,'w' .. (bin and 'b' or ''))
	if not f then
		return nil,err
	end
	if type(content) == 'table' then
		for i = 1,#content do
			f:write(content[i])
		end
	else
		f:write(content)
	end
	f:flush()
	f:close()
end

-- Handles a list of resource files. Each item in the list is a table with the
-- following values:
-- 1: The base directory to copy the file to
-- 2: The resource type (image|css|js|favicon)
-- 3: The name of the file to copy
-- 4: An optional name to refer to the resource
-- 5: `favicon` has a 5th option specifying the favicon's sizes
-- Returns a table that is used by the resource template to include the resource files
function utl.resource(res)
	local resources = {}
	for i = 1,#res do
		local r = res[i]
		if r[2] == 'image' then
			utl.copy('resources/images/' .. r[3],r[1] .. '/img/' .. r[3],true)
		elseif r[2] == 'css' then
			utl.copy('resources/css/' .. r[3],r[1] .. '/css/' .. r[3])
			resources[r[4] or r[3]] = format.CSSLink(r[3])
		elseif r[2] == 'js' then
			utl.copy('resources/js/' .. r[3],r[1] .. '/js/' .. r[3])
			resources[r[4] or r[3]] = format.JSLink(r[3])
		elseif r[2] == 'favicon' then
			utl.copy('resources/images/' .. r[3],r[1] .. '/img/' .. r[3],true)
			resources[r[4] or r[3]] = format.Favicon(r[3],r[5])
		end
	end
	return resources
end

-- Searches for the presence of at least one flag towards the beginning of a
-- table.
function utl.getopt(args,...)
	local flags = {}
	local f = {...}
	for i = 1,#f do
		if #f[i] == 1 then
			flags['-' .. f[i]] = true
		elseif #f[i] > 1 then
			flags['--' .. f[i]] = true
		end
	end

	for i = 1,#args do
		if flags[args[i]] then
			return true
		elseif not args[i]:match('^%-.$') and not args[i]:match('^%-%-.+$') then
			-- arg is not a flag; any proceeding flags wont be at the beginning
			return false
		end
	end
end

return utl