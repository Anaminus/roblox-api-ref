local utl = require 'utl'

local rmd,err = utl.request('http://anaminus.github.io/rbx/raw/rmd/latest.xml')
if not rmd then error(err) end

local explorerImageIndex = {}
for props in rmd:gmatch('<Item class="ReflectionMetadataClass">.-<Properties>(.-)</Properties>') do
	local class,index = props:match('<string name="Name">(.-)</string>.-<string name="ExplorerImageIndex">(.-)</string>')
	if class and index then
		explorerImageIndex[class] = tonumber(index)
	end
end

return explorerImageIndex
