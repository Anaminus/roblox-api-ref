-- Contains utility operations.

local lfs = require 'lfs'
local http = require 'socket.http'
local ltn12 = require 'ltn12'

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