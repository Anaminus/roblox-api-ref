local format = {}

function format.CSSLink(name)
	return '<link href="/api/css/' .. name .. '" rel="stylesheet" type="text/css" media="all">'
end

function format.JSLink(name)
	return '<script type="text/javascript" src="/api/js/' .. name .. '"></script>'
end

function format.Favicon(name,sizes)
	return '<link rel="icon" sizes="' .. sizes .. '" href="/api/img/' .. name .. '">'
end

function format.Tags(tags)
	local o = ''
	if #tags > 0 then
		o = o .. '<span class="api-tag">' ..tags[1] .. '</span>'
		for i = 2,#tags do
			o = o .. ', <span class="api-tag">' ..tags[i] .. '</span>'
		end
	end
	return o
end

function format.Type(type)
	return '<a class="api-value-type" href="#type' .. type .. '">' .. type .. '</a>'
end

function format.Value(value)
	return '<span class="api-value">' .. value .. '</span>'
end

function format.ArgumentName(name)
	return '<span class="api-argument-name">' .. name .. '</span>'
end

function format.MemberName(member)
	local status = (member.Tags.preliminary and ' api-preliminary' or '')
	.. (member.Tags.deprecated and ' api-deprecated' or '')

	return '<a class="api-member-name' .. status .. '" href="#member' .. member.Name .. '">' .. member.Name .. '</a>'
end

function format.ClassName(class,fragment)
	return '<a class="api-class-name" href="/api/class/' .. class .. '.html' .. (fragment and ('#' .. fragment) or '') .. '">' .. class .. '</a>'
end

function format.EnumName(enum)
	return '<span class="api-enum-name">' .. enum .. '</span>'
end

function format.EnumItemName(name)
	return '<span class="api-enum-item-name">' .. name .. '</span>'
end

function format.EnumItemValue(value)
	return '<span class="api-enum-item-value">' .. value .. '</span>'
end

function format.Argument(arg)
	local out = '<span class="api-argument">'
	.. format.Type(arg.Type) .. ' ' .. format.ArgumentName(arg.Name)
	if arg.Default then
		out = out .. ' = ' .. format.Value(arg.Default)
	end
	out = out .. '</span>'
	return out
end

function format.Arguments(args)
	local out = '<span class="api-arguments">( '
	if #args > 0 then
		for i = 1,#args do
			out = out .. format.Argument(args[i])
			if i < #args then out = out .. ', ' end
		end
		out = out .. ' '
	end
	return out .. ')</span>'
end

format.IconSize = 16

function format.ClassIcon(index)
	return '<span class="api-class-icon" style="background-position:-' .. index*format.IconSize .. 'px"></span>'
end

function format.MemberIcon(index)
	return '<span class="api-member-icon" style="background-position:-' .. index*format.IconSize .. 'px"></span>'
end

function format.EnumIcon()
	return '<span class="api-enum-icon"></span>'
end

function format.EnumItemIcon()
	return '<span class="api-enum-item-icon"></span>'
end

function format.ClassTree(tree)
	local o = {}

	local rep = string.rep
	local function r(t,d)
		for i = 1,#t do
			if #t[i].List > 0 then
				o[#o+1] = rep('\t',d) .. '<li>'
				o[#o+1] = rep('\t',d + 1) .. format.ClassIcon(t[i].Icon) .. format.ClassName(t[i].Class)
				o[#o+1] = rep('\t',d + 1) .. '<ul>'
				r(t[i].List,d + 2)
				o[#o+1] = rep('\t',d + 1) .. '</ul>'
				o[#o+1] = rep('\t',d) .. '</li>'
			else
				o[#o+1] = rep('\t',d) .. '<li>' .. format.ClassIcon(t[i].Icon) .. format.ClassName(t[i].Class) .. '</li>'
			end
		end
	end

	r(tree,0)

	return table.concat(o,'\n')
end

function format.Date(date)
	return os.date('!%B %d, %Y',date)
end

do
	local ord = {'st','nd','rd','th','th','th','th','th','th',[0] = 'th'}
	function ordinal(n)
		return n .. ord[math.abs(n)%10]
	end

	local function itemName(item)
		if item.type == 'Class' then
			return format.ClassName(item.Name)
		elseif item.type == 'EnumItem' then
			return item.Enum .. '.' .. item.Name
		elseif item.Class then
			return '<a href="/api/class/' .. item.Class .. '.html#member' .. item.Name .. '">' .. item.Class .. '.' .. item.Name .. '</a>'
		else
			return item.Name
		end
	end

	function format.Diff(diff)
		local subtype = diff[2]
		local item = diff[3]
		local arg = diff[4]
		if diff[1] == -1 then
			if subtype == 'Item' then
				return 'Removed ' .. item.type .. ' ' .. itemName(item)
			elseif subtype == 'Class' or subtype == 'Enum' then
				local r = 'Removed ' .. item.type .. ' ' .. itemName(item) .. '\n<ul>\n'
				for i = 1,#arg do
					r = r .. '\t<li>Removed ' .. arg[i].type .. ' ' .. itemName(arg[i]) .. '</li>\n'
				end
				return r .. '</ul>'
			elseif subtype == 'Tag' then
				return 'Removed ' .. arg .. ' tag from ' .. item.type .. ' ' .. itemName(item)
			end
		elseif diff[1] == 1 then
			if subtype == 'Item' then
				return 'Added ' .. item.type .. ' ' .. itemName(item)
			elseif subtype == 'Class' or subtype == 'Enum' then
				local r = 'Added ' .. item.type .. ' ' .. itemName(item) .. '\n<ul>\n'
				for i = 1,#arg do
					r = r .. '\t<li>Added ' .. arg[i].type .. ' ' .. itemName(arg[i]) .. '</li>\n'
				end
				return r .. '</ul>'
			elseif subtype == 'Tag' then
				return 'Added ' .. arg .. ' tag to ' .. item.type .. ' ' .. itemName(item)
			end
		elseif diff[1] == 0 then
			if subtype == 'Superclass' then
				return 'Changed superclass of ' .. itemName(item)
				.. ' from ' .. (item.SuperClass and format.ClassName(item.Superclass) or '(none)')
				.. ' to ' .. (arg and format.ClassName(arg) or '(none)')
			elseif subtype == 'ValueType' then
				return 'Changed value type of ' .. itemName(item)
				.. ' from ' .. format.Type(item.ValueType)
				.. ' to ' .. format.Type(arg)
			elseif subtype == 'ReturnType' then
				return 'Changed return type of ' .. itemName(item)
				.. ' from ' .. format.Type(item.ReturnType)
				.. ' to ' .. format.Type(arg)
			elseif subtype == 'Arguments' then
				local r = 'Changed arguments of ' .. itemName(item) .. ' ' .. format.Arguments(item.Arguments) .. '\n<ol class="diff-arg-list">\n'
				for i = 1,#arg do
					local d = arg[i]
					if d[1] == 1 then
						r = r .. '\t<li>Inserted ' .. format.Argument(d[3]) .. ' as ' .. ordinal(d[2]) .. ' argument</li>\n'
					elseif d[1] == 2 then
						r = r .. '\t<li>Removed ' .. ordinal(d[2]) .. ' argument</li>\n'
					elseif d[1] == 3 then
						r = r .. '\t<li>Swapped ' .. ordinal(d[2]) .. ' and ' .. ordinal(d[3]) .. ' arguments</li>\n'
					elseif d[1] == 4 then
						r = r .. '\t<li>Replaced ' .. ordinal(d[2]) .. ' argument with ' .. format.Argument(d[3]) .. '</li>\n'
					end
				end
				return r .. '</ol>'
			elseif subtype == 'Value' then
				return 'Changed value of enum item ' .. itemName(item) .. ' from ' .. item.Value .. ' to ' .. arg
			elseif subtype == 'Security' then
				return 'Changed security of ' .. item.type .. ' ' .. itemName(item)
				.. ' from ' .. (arg and arg:match('^(.+)Security$') or 'None')
				.. ' to ' .. (diff[5] and diff[5]:match('^(.+)Security$') or 'None')
			end
		end
		return '<i>Unknown difference</i>'
	end
end

return format
