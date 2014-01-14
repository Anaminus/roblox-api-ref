-- Contains utility operations.

local lfs = require 'lfs'
local http = require 'socket.http'
local ltn12 = require 'ltn12'
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

function utl.exists(filename)
	return not not lfs.attributes(filename)
end

function utl.fileempty(filename)
	local size = lfs.attributes(filename,'size')
	return not size or size == 0
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

-- Creates a directory, also creating parent directories, if necessary.
-- Returns whether the directory was successfully created.
function utl.makedirs(dir)
	local d = ''
	for f in dir:gmatch('[^/]+') do
		d = d .. f .. '/'
		lfs.mkdir(d)
	end
	return lfs.attributes(dir,'mode') == 'directory'
end

-- copies one file to another
function utl.copy(src,dst)
	local a,err = io.open(src,'rb')
	if not a then return nil,err end
	local b,err = io.open(dst,'wb')
	if not b then a:close() return nil,err end
	b:write(a:read('*a'))
	b:flush()
	a:close()
	b:close()
end

-- read content from a file in one go.
function utl.read(file)
	local f,err = io.open(file,'rb')
	if not f then return nil,err end
	local content = f:read('*a')
	f:close()
	return content
end

-- Writes content to a file in one go. Content may be a table.
function utl.write(file,content)
	local f,err = io.open(file,'wb')
	if not f then return nil,err end
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

-- Do http request, failing on non-200 responses.
function utl.request(...)
	local resp = {http.request(...)}
	if not resp[1] then
		return nil,resp[2]
	end
	if resp[2] ~= 200 then
		return nil,'request failed (status ' .. resp[2] .. ')'
	end
	return unpack(resp)
end

-- Copies the response of a http request to a file.
function utl.copyurl(url,dest)
	local sink,err = ltn12.sink.file(io.open(dest,'wb'))
	if not sink then return nil,err end

	local resp,status = utl.request{
		url=url;
		sink=sink;
	}
	if not resp then return nil,status end

	return true
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