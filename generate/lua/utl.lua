-- Contains utility operations.

local lfs = require 'lfs'

local utl = {}

-- normalizes a path's seperators
function utl.normpath(path)
	return path:gsub('[\\/]+','/')
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
-- 2: The resource type (image|css|js)
-- 3: The name of the file to copy
-- Returns a table that is used by the resource template to include the resource files
function utl.resource(res)
	local resources = {}
	for i = 1,#res do
		local r = res[i]
		if r[2] == 'image' then
			utl.copy('resources/images/' .. r[3],r[1] .. '/' .. r[3],true)
		elseif r[2] == 'css' then
			utl.copy('resources/css/' .. r[3],r[1] .. '/' .. r[3])
			resources[#resources+1] = {
				Type = r[2];
				File = r[3];
			}
		elseif r[2] == 'js' then
			utl.copy('resources/js/' .. r[3],r[1] .. '/' .. r[3])
			resources[#resources+1] = {
				Type = r[2];
				File = r[3];
			}
		end
	end
	return resources
end

return utl