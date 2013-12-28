--[[

GetExeVersion( exePath )

returns:
	- High-order word of dwFileVersionMS
	- Low-order word of dwFileVersionMS
	- High-order word of dwFileVersionLS
	- Low-order word of dwFileVersionLS

Thanks:
http://stackoverflow.com/questions/12396665/c-library-to-read-exe-version-from-linux#answer-12486703

]]
local function byte(buf)
	return buf:read(1):byte()
end

local function word(buf, offset)
	buf:seek('set', offset)
	return byte(buf) + byte(buf)*256
end

local function dword(buf, offset)
	buf:seek('set', offset)
	return byte(buf)
		+ byte(buf)*256
		+ byte(buf)*65536
		+ byte(buf)*16777216
end

-- compare a string or a word
local function equals(buf, offset, value)
	if type(value) == 'number' then
		return word(buf, offset) == value
	else
		buf:seek('set', offset)
		return buf:read(#value) == value
	end
end

function hasbit(x, p)
	return x % (p + p) >= p
end

local function pad(x)
	return math.ceil(x/4)*4 % 4294967296
end

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------

local function getVersionPtr(buf)
	if not equals(buf, 0, 'MZ') then
		return nil, 'no MZ_HEADER'
	end

	local pe = word(buf, 0x3C)
	if not equals(buf, pe, 'PE') then
		return nil, 'no PE_HEADER'
	end

	local coff = pe + 4
	local numSections = word(buf, coff + 2)
	local optHeaderSize = word(buf, coff + 16)
	if numSections == 0 or optHeaderSize == 0 then
		return nil, 'no opt header'
	end

	local optHeader = coff + 20
	-- the file we're reading isn't matching up here, but it doesn't seem to matter
--	if not equals(buf, optHeader, 16) then
--		return nil, 'incorrect opt header magic'
--	end

	local dataDir = optHeader + 96
	local vaRes = dword(buf, dataDir + 8*2)
	local secTable = optHeader + optHeaderSize

	for i = 0, numSections-1 do
		local sec = secTable + 40*i
		if equals(buf, sec, '.rsrc') then
			local vaSec = dword(buf, sec + 12)
			local raw = dword(buf, sec + 20)

			local resSec = raw + (vaRes - vaSec)

			local numNamed = word(buf, resSec + 12)
			local numId = word(buf, resSec + 14)

			for j = 0, numNamed+numId-1 do
				local res = resSec + 16 + 8 * j
				local name = dword(buf, res)
				if name == 16 then -- RT_VERSION
					local offs = dword(buf, res + 4)

					if not hasbit(offs, 0x80000000) then
						return nil, 'dir resource'
					end

					-- subtracting should be fine;
					-- high bit isn't 0 as this point, and dwords are always 32-bits
					local verDir = resSec + (offs - 0x80000000) -- band(offs, 0x7FFFFFFF)


					numNamed = word(buf, verDir + 12)
					numId = word(buf, verDir + 14)
					if numNamed == 0 and numId == 0 then
						return nil, 'empty'
					end
					res = verDir + 16
					offs = dword(buf, res + 4)
					if not hasbit(offs, 0x80000000) then
						return nil, 'dir resource 2'
					end

					verDir = resSec + (offs - 0x80000000) -- band(offs, 0x7FFFFFFF)
					numNamed = word(buf, verDir + 12)
					numId = word(buf, verDir + 14)
					if numNamed == 0 and numId == 0 then
						return nil, 'empty 2'
					end
					res = verDir + 16
					offs = dword(buf, res + 4)
					if hasbit(offs, 0x80000000) then
						return nil, 'dir resource 3'
					end
					verDir = resSec + offs

					local verVa = dword(buf, verDir)
					local verSize = dword(buf, verDir + 4)

					local verPtr = raw + (verVa - vaSec)
					return verPtr, verSize
				end
			end
		end
	end
	return nil, 'nope'
end

local function parseVersionInfo(buf, version)
	local offs = 0
	offs = pad(offs)

	local len = word(buf, version + offs)
	offs = offs + 2
	local valLen = word(buf, version + offs)
	offs = offs + 2
	local type = word(buf, version + offs)
	offs = offs + 2

	local info = ''
	for i = 0, 200 do
		buf:seek('set', version + offs)
		local c = buf:read(2)
		if c == '\0\0' then
			break
		end
		offs = offs + 2
		info = info .. c:sub(1, 1)
	end

	offs = pad(offs)

	if type ~= 0 then -- TEXT
		local value = ''
		for i = 0, valLen-1 do
			buf:seek('set', version + offs)
			local c = buf:read(2)
			offs = offs + 2
			value = value .. c:sub(1, 1)
		end
		return value
	else
		if info == 'VS_VERSION_INFO' then
			-- fixed is a VS_FIXEDFILEINFO
			local fixed = version + offs
			return {
				dwSignature        = dword(buf, fixed +  4);
				dwStrucVersion     = dword(buf, fixed +  8);
				dwFileVersionMS    = dword(buf, fixed + 12);
				dwFileVersionLS    = dword(buf, fixed + 16);
				dwProductVersionMS = dword(buf, fixed + 20);
				dwProductVersionLS = dword(buf, fixed + 24);
				dwFileFlagsMask    = dword(buf, fixed + 28);
				dwFileFlags        = dword(buf, fixed + 32);
				dwFileOS           = dword(buf, fixed + 36);
				dwFileType         = dword(buf, fixed + 40);
				dwFileSubtype      = dword(buf, fixed + 44);
				dwFileDateMS       = dword(buf, fixed + 48);
				dwFileDateLS       = dword(buf, fixed + 52);
			}
		end
		offs = offs + valLen
	end
end

return function(file)
	local buf, err = io.open(file, 'rb')
	if not buf then
		return nil, err
	end

	local ptr, err = getVersionPtr(buf)
	if not ptr then
		error(err, 2)
	end

	local info = parseVersionInfo(buf, ptr)
	buf:close()

	-- return high-order word from dword
	local function h(n)
		return math.floor( (n + 65536) / 65536 ) - 1
	end

	-- return low-order word from dword
	local function l(n)
		return (n * 65536) % 4294967296 / 65536
	end

	return
		h(info.dwFileVersionMS),
		l(info.dwFileVersionMS),
		h(info.dwFileVersionLS),
		l(info.dwFileVersionLS)
end
