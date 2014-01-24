local slt = require 'slt2'
local utl = require 'utl'

local format = {}

function format.html(str)
	return tostring(str)
		:gsub('&','&amp;')
		:gsub("'",'&apos;')
		:gsub('<','&lt;')
		:gsub('>','&gt;')
		:gsub('"','&quot;')
end

local templateCache = {}
function format.slt(file,data)
	file = utl.path('resources/templates',file)
	data.html = format.html
	if templateCache[file] then
		return slt.render(templateCache[file],data)
	else
		local t = slt.loadfile(file,'{{','}}')
		templateCache[file] = t
		return slt.render(t,data)
	end
end

format.url = {}

function format.url.raw(str)
	return str:gsub('[^-%.0-9A-Za-z_~]',function(c)
		return ('%%%02X'):format(c:byte())
	end)
end

function format.url.type(type)
	return '#type' .. format.url.raw(type)
end

function format.url.class(class)
	return '/api/class/' .. format.url.raw(class) .. '.html'
end

function format.url.member(class,member)
	if member then
		return '/api/class/' .. format.url.raw(class) .. '.html#member' .. format.url.raw(member)
	else
		member = class
		return '#member' .. format.url.raw(member)
	end
end

function format.classtree(tree)
	local o = {}

	local rep = string.rep
	local function r(t,d)
		for i = 1,#t do
			local n = #t[i].List > 0
			o[#o+1] = rep('\t',d) .. '<li>'
			if n then
				o[#o+1] = '\n' .. rep('\t',d + 1)
			end
			o[#o+1] = format.slt('ClassIcon.html',{icon=t[i].Icon}) .. '<a class="api-class-name" href="' .. format.url.class(t[i].Class) .. '">' .. t[i].Class .. '</a>'
			if n then
				o[#o+1] = '\n' .. rep('\t',d + 1) .. '<ul>\n'
				r(t[i].List,d + 2)
				o[#o+1] = rep('\t',d + 1) .. '</ul>\n'
				o[#o+1] = rep('\t',d)
			end
			o[#o+1] = '</li>'
			o[#o+1] = '\n'
		end
	end

	r(tree,0)

	return table.concat(o,nil,1,#o-1)
end

function format.date(date)
	return os.date('!%B %d, %Y',date)
end

function format.difflink(diff)
	return 'v' .. diff.CurrentVersion:match('^(%d+%.%d+)')
end

do
	local ord = {'st','nd','rd','th','th','th','th','th','th',[0] = 'th'}
	function format.ordinal(n)
		return n .. ord[math.abs(n)%10]
	end
end

return format
