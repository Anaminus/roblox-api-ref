--[[

FetchAPI

Retrieves Roblox API data from the website.

Returns two values: The parsed API dump string, and a table of class names and
their corresponding explorer image indexes.

Dependencies:
	- LuaFileSystem
	- LuaSocket
	- LuaZip
	- LexAPI

]]

-- Combines arguments into a path, and normalizes
local function path(...)
	local a = {...}
	local p = a[1] or ''
	for i = 2,#a do
		p = p .. '/' .. a[i]
	end
	return p:gsub('[\\/]+','/')
end

-- Returns a directory of a Roblox installation.
-- `type`: "player" or "studio"
-- Implementation is OS dependent.
local function getRobloxDir(type)
	-- Windows 7 64-bit
	local lfs = require 'lfs'
	local versions = 'C:/Program Files (x86)/Roblox/Versions/'
	for dir in lfs.dir(versions) do
		local version = path(versions,dir)
		if dir ~= '.' and dir ~= '..' and lfs.attributes(version, 'mode') == 'directory' then
			local exe = type == 'studio' and 'RobloxStudioBeta.exe' or 'RobloxPlayerBeta.exe'
			local f = io.open(path(version,exe),'rb')
			if f then
				f:close()
				return version
			end
		end
	end
	return nil,'could not find installation'
end

-- Get data from the user's Roblox installation
local function getLocalSource(rbxPlayerDir,rbxStudioDir)
	local rbxPlayerDir = rbxPlayerDir --or getRobloxDir('player')
	if not rbxPlayerDir then
		return nil,'Roblox player not installed'
	end

	local rbxStudioDir = rbxStudioDir --or getRobloxDir('studio')
	if not rbxStudioDir then
		return nil,'Roblox studio not installed'
	end

	-- get reflection metadata
	local rmd do
		local a = io.open(path(rbxStudioDir,'ReflectionMetadata.xml'),'r')
		if not a then
			return nil,'could not find ReflectionMetadata in studio installation'
		end
		local b = io.open(path(rbxPlayerDir,'ReflectionMetadata.xml'),'w')
		rmd = a:read('*a')
		-- copy to player folder for API dump
		b:write(rmd)
		b:flush()
		a:close()
		b:close()
	end

	-- dump API
	local apiDump do
		local lfs = require 'lfs'
		local dir = lfs.currentdir()
		lfs.chdir(rbxPlayerDir)
		if os.execute('RobloxPlayerBeta --API api.dmp') ~= 0 then
			lfs.chdir(dir)
			return nil,'failed to dump API'
		end
		local f = io.open('api.dmp','r')
		if not f then
			lfs.chdir(dir)
			return nil,'failed to find API dump'
		end
		apiDump = f:read('*a')
		f:close()
		os.remove('api.dmp')
		lfs.chdir(dir)
	end

	local explorerIndex = {}
	for props in rmd:gmatch('<Item class="ReflectionMetadataClass">.-<Properties>(.-)</Properties>') do
		local class,index = props:match('<string name="Name">(.-)</string>.-<string name="ExplorerImageIndex">(.-)</string>')
		if class and index then
			explorerIndex[class] = tonumber(index)
		end
	end

	return require('LexAPI')(apiDump),explorerIndex
end

--[[
Files required to successfully dump API:
	RobloxPlayerBeta.exe
	AppSettings.xml
	boost.dll
	fmodex.dll
	Log.dll
	OgreMain.dll
	tbb.dll
	content (directory)
	ReflectionMetadata.xml

Server:
	http://setup.roblox.com

Version hashes:
	versionPlayer: /version
	versionStudio: /versionQTStudio

Archives:
	/version-<versionPlayer>-RobloxApp.zip
	/version-<versionPlayer>-Libraries.zip
	/version-<versionStudio>-RobloxStudio.zip

	Each file is usually a couple MB in size, hence why this is the slowest
	method.

Manual:
	AppSettings.xml
		<?xml version="1.0" encoding="UTF-8"?>
		<Settings>
			<ContentFolder>content</ContentFolder>
			<BaseUrl>http://www.roblox.com</BaseUrl>
		</Settings>
]]

-- Get data directly from install server
local function getWebsiteSource()
	local lfs = require 'lfs'
	local http = require 'socket.http'

	-- Base domain. Might be useful for fetching from test sites.
	local base = 'roblox.com'

	-- Temp directory for downloaded files.
	local tmp = path(os.getenv('TEMP'),'lua-get-cache/')
	lfs.mkdir(tmp)

	-- Get latest version hashes of player and studio.
	local versionPlayer = http.request('http://setup.' .. base .. '/version')
	local versionStudio = http.request('http://setup.' .. base .. '/versionQTStudio')

	local playerDir = path(tmp,versionPlayer)
	local studioDir = path(tmp,versionStudio)

	-- zip file name; unzip location
	local zips = {}

	local function exists(file)
		return not not lfs.attributes(file)
	end

	-- If player needs updating
	if not exists(playerDir) then
		lfs.mkdir(playerDir)

		-- AppSettings must be created manually
		local app = io.open(path(playerDir,'AppSettings.xml'),'w')
		app:write([[
<?xml version="1.0" encoding="UTF-8"?>
<Settings>
	<ContentFolder>content</ContentFolder>
	<BaseUrl>http://www.]] .. base .. [[</BaseUrl>
</Settings>]])
		app:flush()
		app:close()

		-- Content directory is required by the exe
		lfs.mkdir(path(playerDir,'content'))

		zips[#zips+1] = {versionPlayer .. '-RobloxApp.zip', playerDir}
		zips[#zips+1] = {versionPlayer .. '-Libraries.zip', playerDir}
	end

	-- If studio needs updating
	if not exists(studioDir) then
		lfs.mkdir(studioDir)
		zips[#zips+1] = {versionStudio .. '-RobloxStudio.zip', studioDir};
	end

	if #zips > 0 then
		local zip = require 'zip'
		-- Temp zip file location
		local ztmp = os.tmpname()

		-- Get any files that need updating
		for i = 1,#zips do
			local zipn = zips[i][1]
			local dir = zips[i][2]

			-- Request the current zip file
			http.request{
				url = 'http://setup.' .. base .. '/' .. zipn;
				sink = ltn12.sink.file(io.open(ztmp,'wb'));
			}

			-- Unzip
			local zipfile = zip.open(ztmp)
			if not zipfile then
				return nil,'failed to get file `' .. zipn .. '`'
			end
			for data in zipfile:files() do
				local filename = data.filename
				if filename:sub(-1,-1) ~= '/' then
				-- If file is not a directory
					-- Copy file to given folder
					local zfile = assert(zipfile:open(filename))
					local file = assert(io.open(path(dir,filename),'wb'))
					file:write(zfile:read('*a'))
					file:flush()
					file:close()
					zfile:close()
				end
			end
			zipfile:close()
		end
		-- remote temp zip file
		os.remove(ztmp)
	end

	-- Now local source can properly handle the files
	return getLocalSource(playerDir,studioDir)
end

local data = {getWebsiteSource()}
if data[1] == nil then
	error(data[2],2)
end

return data
