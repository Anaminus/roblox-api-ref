local utl = require 'utl'

local api,err = utl.request('http://anaminus.github.io/rbx/raw/api/latest.txt')
if not api then error(err) end

local rmd,err = utl.request('http://anaminus.github.io/rbx/raw/rmd/latest.xml')
if not rmd then error(err) end

local explorerIndex = {}
for props in rmd:gmatch('<Item class="ReflectionMetadataClass">.-<Properties>(.-)</Properties>') do
	local class,index = props:match('<string name="Name">(.-)</string>.-<string name="ExplorerImageIndex">(.-)</string>')
	if class and index then
		explorerIndex[class] = tonumber(index)
	end
end

return {require('LexAPI')(api),explorerIndex}
