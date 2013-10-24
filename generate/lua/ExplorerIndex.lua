-- Retrieves a table of classes and their ExplorerImageIndex numbers.

local CachedGet = require 'CachedGet'

local source = CachedGet(
	[[http://wiki.roblox.com/index.php?title=Class_reference/Explorer_index/raw&action=raw]],
	'ExplorerIndex.txt'
)

local data = {}
for class,index in source:gmatch('([^\r\n]+)\t(%d+)') do
	data[class] = tonumber(index)
end

return data
