local utl = require 'utl'

local rmd,err = utl.request('http://anaminus.github.io/rbx/raw/rmd/latest.xml')
if not rmd then
	rmd = utl.read(utl.path('../cache/ReflectionMetadata.xml'))

	if rmd then
		print('could not get latest ReflectionMetadata; using cached version')
	else
		error(err)
	end
end

utl.write(utl.path('../cache/ReflectionMetadata.xml',rmd))

local explorerImageIndex = {}
for props in rmd:gmatch('<Item class="ReflectionMetadataClass">.-<Properties>(.-)</Properties>') do
	local class,index = props:match('<string name="Name">(.-)</string>.-<string name="ExplorerImageIndex">(.-)</string>')
	if class and index then
		explorerImageIndex[class] = tonumber(index)
	end
end

return explorerImageIndex
