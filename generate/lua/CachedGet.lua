--[[

CachedGet ( url, file, bin, exp )

	Sends an HTTP GET request, caching the results for subsequent calls.

	`url`: The URL to request.
	`file`: The name of the cache file.
	`bin`: Whether content is binary. Defaults to false.
	`exp`: Cache expiration time, in seconds. Defaults to 1 day.

]]

local http = require 'socket.http'
local lfs = require 'lfs'

return function(url,file,bin,exp)
	local cache = os.getenv('TEMP') .. '/lua-get-cache/'
	lfs.mkdir(cache)

	file =  cache .. file
	bin = bin and 'b' or ''

	local content

	local mod = lfs.attributes(file,'modification')
	if mod and os.difftime(os.time(),mod) < (exp or 1*60*60*24) then
	-- if the last time the file was updated is within the expiration time
		-- get the content from the cache

		local f = io.open(file,'r' .. bin)
		if f then
			content = f:read('*a')
			f:close()

		end
	end

	if not content then

	-- if the cached file expired or cached file did not exist
		-- send the request
		local src,err = http.request(url)
		if src then

			content = src
			-- update the cache
			local f = io.open(file,'w' .. bin)
			if f then
				f:write(src)
				f:flush()
				f:close()
			end
		else

			return nil,err
		end
	end

	return content
end
