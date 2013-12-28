--[[

Returns []Diff

type Diff struct {
	Date            int
	PreviousVersion string
	CurrentVersion  string
}

]]

local utl = require 'utl'
local FetchAPI = require 'FetchAPI'
local LexAPI = require 'LexAPI'
local DiffAPI = require 'DiffAPI'
local GetExeVersion = require 'GetExeVersion'

local list = require 'ParseVersionList' (utl.path('..','data','versions.txt'))

local versions = {}
for i = 1,#list do
	local v = list[i]
	print("Diff: fetching API (" .. tostring(v[2]) .. ")")
	local dump,index,exec = FetchAPI(v[2],v[3])
	if dump then
		local ver = {GetExeVersion(exec)}
		if #ver > 0 then
			ver = table.concat(ver,'.')
		else
			ver = v[2] or v[3]
		end
		-- version,date,dump
		versions[#versions+1] = {ver,v[1],LexAPI(dump)}
	else
		print("Fetch failed:",index)
	end
end

local diffs = {}
for i = 1,#versions-1 do
	local a = versions[i+1]
	local b = versions[i]

	local d = DiffAPI(a[3],b[3])
	if #d > 0 then
		diffs[#diffs+1] = {
			Date = b[2];
			PreviousVersion = a[1];
			CurrentVersion = b[1];
			Differences = d;
		}
	end
end

return diffs
