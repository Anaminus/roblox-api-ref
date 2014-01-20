--[[

Returns []Diff

type Diff struct {
	Date            int
	PreviousVersion string
	CurrentVersion  string
	Differences     table
}

]]

local utl = require 'utl'
local ParseVersions = require 'ParseVersions'
local CompareVersions = require 'CompareVersions'
local LexAPI = require 'LexAPI'
local DiffAPI = require 'DiffAPI'

local cache = utl.path('../cache')
if not utl.makedirs(cache) then error("could not make cache folder") end

local buildDiffs do
	local header,err = utl.request('http://anaminus.github.io/rbx/raw/header.txt')
	if not header then error(err) end

	local latest,err = ParseVersions(header)
	if not latest then error(err) end

	local current = utl.read(utl.path('../cache/header.txt'))
	if current then
		current = require 'ParseVersions' (current)
	end
	if not current then
		current = {Schema=latest.Schema,Domain=latest.Domain,List={}}
	end

	buildDiffs = require 'CompareVersions' (current,latest)
end

local header,err = io.open(utl.path('../cache/header.txt'),'wb')
if not header then error(err) end

header:write('schema 1\nroblox.com\nDate\tPlayerHash\tStudioHash\tPlayerVersion\n')
header:flush()

local versions = {}
for i = 1,#buildDiffs do
	local status = buildDiffs[i][1]
	local build = buildDiffs[i][2]
	local dest = utl.path(cache,build.PlayerHash .. '.txt')

	if status == 1 then
		print("Diff update: fetching " .. build.PlayerHash)
		local s,err = utl.copyurl(
			'http://anaminus.github.io/rbx/raw/api/' .. build.PlayerHash .. '.txt',
			dest
		)
		if not s then error(err) end

		local dump,err = utl.read(dest)
		if not dump then error(err) end

		versions[#versions+1] = {build.PlayerVersion,build.Date,LexAPI(dump)}
		header:write(build.Date,'\t',build.PlayerHash,'\t',build.StudioHash,'\t',build.PlayerVersion,'\n')
		header:flush()
	elseif status == 0 then
		if utl.fileempty(dest) then
			print("Diff check: fetching " .. build.PlayerHash)
			local s,err = utl.copyurl(
				'http://anaminus.github.io/rbx/raw/api/' .. build.PlayerHash .. '.txt',
				dest
			)
			if not s then error(err) end
		end

		local dump,err = utl.read(dest)
		if not dump then error(err) end

		versions[#versions+1] = {build.PlayerVersion,build.Date,LexAPI(dump)}
		header:write(build.Date,'\t',build.PlayerHash,'\t',build.StudioHash,'\t',build.PlayerVersion,'\n')
		header:flush()
	elseif status == -1 then
		print("Diff: removing " .. build.PlayerHash)
		os.remove(dest)
	end
end
header:close()

local diffs = {}
for i = #versions-1,1,-1 do
	local a = versions[i]
	local b = versions[i+1]

	local d = DiffAPI(a[3],b[3])
	if #d > 0 then
		if b[1]:match('^0%.79%.%d+%.%d+$') then
			-- ignore superclass changes
			local i,n = 1,#d
			while i <= n do
				if d[i][1] == 0 and d[i][2] == 'Superclass' then
					table.remove(d,i)
					n = n - 1
				else
					i = i + 1
				end
			end
		elseif b[1]:match('^0%.80%.%d+%.%d+$') then
			-- ignore enum additions
			local i,n = 1,#d
			while i <= n do
				if d[i][1] == 1 and d[i][2] == 'Enum' then
					table.remove(d,i)
					n = n - 1
				else
					i = i + 1
				end
			end
		end

		for i = 1,#d do
			local diff = d[i]
			if diff[2] == 'Security' then
				local t = diff[4]
				diff[4] = t and (t:match('^(.+)Security$') or t) or 'None'

				local t = diff[5]
				diff[5] = t and (t:match('^(.+)Security$') or t) or 'None'
			end
		end

		diffs[#diffs+1] = {
			Date = b[2];
			PreviousVersion = a[1];
			CurrentVersion = b[1];
			Differences = d;
		}
	end
end

return diffs
