-- Retrieves and parses the current API dump.

local CachedGet = require 'CachedGet'

local source = CachedGet(
	[[http://wiki.roblox.com/index.php?title=Class_reference/API_dump/raw&action=raw]],
	'APIDump.txt'
)

return require('LexAPI')(source)
