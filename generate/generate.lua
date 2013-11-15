if #({...}) == 0 then
	print([[
USAGE

lua generate.lua [-c] [folders]

folders               One or more folders to output generated files.
-c         --clear    Clear folders before outputting.
]])
	return
end

-- add lua directory to path
do
	local c = {}
	for l in package.config:gmatch('[^\r\n]+') do
		c[#c+1] = l
	end

	-- ';./lua/?.lua'
	package.path = package.path .. table.concat{c[2],'.',c[1],'lua',c[1],c[3],'.lua'}
end

local utl = require 'utl'
local slt = require 'slt2'
local format = require 'format'

local API = require 'API'
local APIDump,ExplorerIndex = unpack(require 'APIDump')
local APIjson = require'APIToJSON'(APIDump,true)

local ParseDescription = require 'ParseDescription'

local tmplIndex = slt.loadfile('resources/templates/index.html','{{','}}')
local tmplClass = slt.loadfile('resources/templates/class.html','{{','}}')

local function generate(base)
	utl.makedir(utl.path(base,'class'))
	utl.makedir(utl.path(base,'class','img'))
	utl.makedir(utl.path(base,'img'))
	utl.makedir(utl.path(base,'css'))
	utl.makedir(utl.path(base,'js'))

	local resources = utl.resource({
		{base,'image','icon-explorer.png'};
		{base,'image','icon-objectbrowser.png'};

		{base,'css','api.css'};
		{base,'css','ref.css'};

		{base,'js','jquery-1.10.2.min.js','jquery.js'};
		{base,'js','fuse.min.js','fuse.js'};

		{base,'js','search.js'};
	})

	utl.write(utl.path(base,'search-db.json'),APIjson)

	-- index.html
	utl.write(utl.path(base,'index.html'),
		slt.render(tmplIndex,{
			format = format;
			resources = resources;
			tree = API.ClassTree();
		}) --:gsub('[\r\n\t]*','')
	)

	do
		local dir = utl.path('..','data','class','img')
		for name in lfs.dir(dir) do
			local file = utl.path(dir,name)
			if lfs.attributes(file,'mode') == 'file' then
				utl.copy(file,utl.path(base,'class','img',name),true)
			end
		end
	end

	local function writeClass(class)
		local f = io.open(utl.path(base,'class',class .. '.html'),'w')

		local classData = API.ClassData(class)
		local description = ParseDescription(utl.path('..','data','class',class .. '.md'))
		local memberDesc = description.members
		if memberDesc then
			for i = 1,#classData.Members do
				local list = classData.Members[i].List
				for i = 1,#list do
					local desc = memberDesc[list[i].Name]
					if desc then
						list[i].Description = desc
					end
				end
			end
		end

		local output = slt.render(tmplClass,{
			format = format;
			resources = resources;
			class = classData;
			description = description;
		}) --:gsub('[\r\n\t]*','')
		f:write(output)
		f:flush()
		f:close()
	end

	for i = 1,#APIDump do
		if APIDump[i].type == 'Class' then
			writeClass(APIDump[i].Name)
		end
	end
end

local args = {...}
local clearFolders = false
if utl.getopt(args,'c','clear') then
	table.remove(args,1)
	clearFolders = true
end
for i = 1,#args do
	local base = utl.path(args[i],'api')
	if clearFolders then utl.cleardir(base) end
	generate(base)
	print('generated',args[i])
end
