--[[

Returns list of tables.

First entry:
	-1: remove all files related to the build
	 0: no change; verify that files for build are intact
	 1: update files; build was added or changed

Second entry: A table of info for the build

]]

return function(a,b)
	local diffs = {}
	local al,bl = a.List,b.List

	local as,bs = {},{}
	for i = 1,#al do
		as[al[i].PlayerHash] = al[i]
	end
	for i = 1,#bl do
		bs[bl[i].PlayerHash] = bl[i]
	end

	for bref,bbuild in pairs(bs) do
		if as[bref] then
			local abuild = as[bref]
			local changed = false
			for k,v in pairs(bbuild) do
				if abuild[k] ~= v then
					-- change
					changed = true
					diffs[#diffs+1] = {1,bbuild}
					break
				end
			end
			if not changed then
				diffs[#diffs+1] = {0,bbuild}
			end
		else
			-- add
			diffs[#diffs+1] = {1,bbuild}
		end
	end

	for aref,abuild in pairs(as) do
		if not bs[aref] then
			-- remove
			diffs[#diffs+1] = {-1,abuild}
		end
	end

	table.sort(diffs,function(a,b)
		return a[2].Date < b[2].Date
	end)

	return diffs
end
