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
local resource = require 'resource'

local APIDiffs,APIDump = unpack(require 'APIDiffs')
local API = require 'API'
local APIjson = require'APIToJSON'(APIDump,true)

local ParseDescription = require 'ParseDescription'

local tmplIndex = slt.loadfile('resources/templates/index.html','{{','}}')
local tmplDiff = slt.loadfile('resources/templates/diff.html','{{','}}')
local tmplClass = slt.loadfile('resources/templates/class.html','{{','}}')
local tmplEnum = slt.loadfile('resources/templates/enum.html','{{','}}')
local tmplAbout = slt.loadfile('resources/templates/about.html','{{','}}')
local tmplFAQ = slt.loadfile('resources/templates/faq.html','{{','}}')

local function generate(base)
	utl.makedirs(utl.path(base,'class'))
	utl.makedirs(utl.path(base,'class','img'))
	utl.makedirs(utl.path(base,'type'))
	utl.makedirs(utl.path(base,'type','img'))
	utl.makedirs(utl.path(base,'img'))
	utl.makedirs(utl.path(base,'css'))
	utl.makedirs(utl.path(base,'js'))

	local resources = resource({
		{base,'favicon','favicon16.png', 'favicon16', '16x16'};

		{base,'image','icon-explorer.png'};
		{base,'image','icon-objectbrowser.png'};

		{base,'css','ref.css'};

		{base,'js','jquery-1.10.2.min.js','jquery.js'};

		{base,'js','search.js'};
		{base,'js','collapse.js'};
	})

	utl.write(utl.path(base,'search-db.json'),APIjson)

	utl.write(utl.path(base,'index.html'),
		slt.render(tmplIndex,{
			format = format;
			resources = resources;
			diffs = APIDiffs;
			tree = API.ClassTree(APIDump);
			html = format.html;
		})
	)

	utl.write(utl.path(base,'diff.html'),
		slt.render(tmplDiff,{
			format = format;
			resources = resources;
			diffs = APIDiffs;
			html = format.html;
		})
	)

	utl.write(utl.path(base,'about.html'),
		slt.render(tmplAbout,{
			format = format;
			resources = resources;
			html = format.html;
		})
	)

	utl.write(utl.path(base,'faq.html'),
		slt.render(tmplFAQ,{
			format = format;
			resources = resources;
			html = format.html;
		})
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

	do
		local dir = utl.path('..','data','type','img')
		for name in lfs.dir(dir) do
			local file = utl.path(dir,name)
			if lfs.attributes(file,'mode') == 'file' then
				utl.copy(file,utl.path(base,'type','img',name),true)
			end
		end
	end

	local function writeClass(class)
		local f = io.open(utl.path(base,'class',format.url.file(class) .. '.html'),'w')

		local output = slt.render(tmplClass,{
			format = format;
			resources = resources;
			class = API.ClassData(APIDump,class);
			html = format.html;
		})
		f:write(output)
		f:flush()
		f:close()
	end

	local function writeEnum(enum)
		local f = io.open(utl.path(base,'type',format.url.file(enum) .. '.html'),'w')

		local output = slt.render(tmplEnum,{
			format = format;
			resources = resources;
			enum = API.EnumData(APIDump,enum);
			html = format.html;
		})

		f:write(output)
		f:flush()
		f:close()
	end

	for i = 1,#APIDump do
		if APIDump[i].type == 'Class' then
			writeClass(APIDump[i].Name)
		elseif APIDump[i].type == 'Enum' then
			writeEnum(APIDump[i].Name)
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
