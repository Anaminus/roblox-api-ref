local format = {}

function format.CSSLink(name)
	return '<link href="/api/css/' .. name .. '" rel="stylesheet" type="text/css" media="all">'
end

function format.JSLink(name)
	return '<script type="text/javascript" src="/api/js/' .. name .. '"></script>'
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

	return '<a class="api-member-name' .. status .. '" id="member' .. member.Name .. '">' .. member.Name .. '</a>'
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

function format.Arguments(args)
	local out = '<span class="api-arguments">( '
	if #args > 0 then
		for i = 1,#args do
			local arg = args[i]
			out = out .. '<span class="api-argument">'
			.. format.Type(arg.Type) .. ' ' .. format.ArgumentName(arg.Name)
			if arg.Default then
				out = out .. ' = ' .. format.Value(arg.Default)
			end
			out = out .. '</span>'
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

return format
