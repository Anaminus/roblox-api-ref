--[[
-- slt2 - Simple Lua Template 2
--
-- Project page: https://github.com/henix/slt2
--
-- @License
-- MIT License
--
-- @Copyright
-- Copyright (C) 2012-2013 henix.
--]]

--[[
Enhancements:
    - If a tag begins a new line, the newline and any indentation will be
      collapsed.
    - If an expression or inclusion tag begins a new line, then the result of
      the tag will take on the same indentation as the tag.

]]

local slt2 = {}

-- indent each line of a string, except the first
local function indent_string(str, indent)
	local output = string.gsub(str, '(\r?\n)(.-)', '%1'..indent..'%2')
	return output
end

-- a tree fold on inclusion tree
-- @param init_func: must return a new value when called
local function include_fold(template, start_tag, end_tag, fold_func, init_func)
	local result = init_func()

	start_tag = start_tag or '#{'
	end_tag = end_tag or '}#'
	local start_tag_inc = start_tag..'include:'

	local start1, end1 = string.find(template, start_tag_inc, 1, true)
	local start2 = nil
	local end2 = 0

	while start1 ~= nil do
		local indent
		if start1 > end2 + 1 then -- for beginning part of file
			local out = string.sub(template, end2 + 1, start1 - 1)

			-- if tag starts on its own line, collapse whitespace between newline and tag
			local _,ln = string.find(out, '.*\n')
			if ln or end2 == 0 then
				ln = ln or 1
				if not string.match(string.sub(out, ln + 1), '[^\t ]') then
					indent = string.sub(out, ln + 1)
				end
			end

			result = fold_func(result, out)
		end
		start2, end2 = string.find(template, end_tag, end1 + 1, true)
		assert(start2, 'end tag "'..end_tag..'" missing')
		do -- recursively include the file
			local filename = assert(loadstring('return '..string.sub(template, end1 + 1, start2 - 1)))()
			assert(filename)
			local fin = assert(io.open(filename))
			-- TODO: detect cyclic inclusion?
			if indent then
				result = fold_func(result, include_fold(indent_string(fin:read('*a'), indent), start_tag, end_tag, fold_func, init_func), filename)
			else
				result = fold_func(result, include_fold(fin:read('*a'), start_tag, end_tag, fold_func, init_func), filename)
			end
			fin:close()
		end
		start1, end1 = string.find(template, start_tag_inc, end2 + 1, true)
	end
	result = fold_func(result, string.sub(template, end2 + 1))
	return result
end

-- preprocess included files
-- @return string
function slt2.precompile(template, start_tag, end_tag)
	return table.concat(include_fold(template, start_tag, end_tag, function(acc, v)
		if type(v) == 'string' then
			table.insert(acc, v)
		elseif type(v) == 'table' then
			table.insert(acc, table.concat(v))
		else
			error('Unknown type: '..type(v))
		end
		return acc
	end, function() return {} end))
end

-- unique a list, preserve order
local function stable_uniq(t)
	local existed = {}
	local res = {}
	for _, v in ipairs(t) do
		if not existed[v] then
			table.insert(res, v)
			existed[v] = true
		end
	end
	return res
end

-- @return { string }
function slt2.get_dependency(template, start_tag, end_tag)
	return stable_uniq(include_fold(template, start_tag, end_tag, function(acc, v, name)
		if type(v) == 'string' then
		elseif type(v) == 'table' then
			if name ~= nil then
				table.insert(acc, name)
			end
			for _, subname in ipairs(v) do
				table.insert(acc, subname)
			end
		else
			error('Unknown type: '..type(v))
		end
		return acc
	end, function() return {} end))
end

-- @return { name = string, code = string / function}
function slt2.loadstring(template, start_tag, end_tag, tmpl_name)
	-- compile it to lua code
	local lua_code = {}

	start_tag = start_tag or '#{'
	end_tag = end_tag or '}#'

	local output_func = "coroutine.yield"

	template = slt2.precompile(template, start_tag, end_tag)

	-- find first start tag
	local start1, end1 = string.find(template, start_tag, 1, true)
	local start2 = nil
	local end2 = 0

	local cEqual = string.byte('=', 1)

	while start1 ~= nil do
		local indent
		if start1 > end2 + 1 then
			-- content between previous end tag and current start tag
			local out = string.sub(template, end2 + 1, start1 - 1)

			-- if tag starts on its own line, collapse whitespace between newline and tag
			local _,ln = string.find(out, '.*\n')
			if ln or end2 == 0 then
				ln = ln or 1
				if not string.match(string.sub(out, ln + 1), '[^\t ]') then
					-- do not apply to expression
					if string.byte(template, end1 + 1) ~= cEqual then
						if string.sub(out, ln - 1, ln - 1) == '\r' then
							-- remove CRLF-style line
							out = string.sub(out, 1, ln - 2)
						else
							out = string.sub(out, 1, ln - 1)
						end
					else
						-- store the indentation; will be applied to the expression result later
						indent = string.format('%q',string.sub(out, ln + 1))
					end
				end
			end

			-- output content as literal
			table.insert(lua_code, output_func..'('..string.format("%q", out)..')')
		end
		-- find end tag
		start2, end2 = string.find(template, end_tag, end1 + 1, true)
		assert(start2, 'end_tag "'..end_tag..'" missing')
		if string.byte(template, end1 + 1) == cEqual then
		-- if start tag is expression
			-- output content between start and end tags as literal
			if indent then
				-- return indentation, which will be applied to each line of the result
				table.insert(lua_code, output_func..'('..string.sub(template, end1 + 2, start2 - 1)..', '..indent..')')
			else
				table.insert(lua_code, output_func..'('..string.sub(template, end1 + 2, start2 - 1)..')')
			end
		else
			-- output content between start and end tags as lua
			table.insert(lua_code, string.sub(template, end1 + 1, start2 - 1))
		end
		-- find start tag
		start1, end1 = string.find(template, start_tag, end2 + 1, true)
	end
	-- output remaining content after last end tag was literal
	table.insert(lua_code, output_func..'('..string.format("%q", string.sub(template, end2 + 1))..')')

	local ret = { name = tmpl_name or '=(slt2.loadstring)' }
	if setfenv == nil then -- lua 5.2
		ret.code = table.concat(lua_code, ' ')
	else -- lua 5.1
		ret.code = assert(loadstring(table.concat(lua_code, ' '), ret.name))
	end
	return ret
end

-- @return { name = string, code = string / function }
function slt2.loadfile(filename, start_tag, end_tag)
	local fin = assert(io.open(filename))
	local all = fin:read('*a')
	fin:close()
	return slt2.loadstring(all, start_tag, end_tag, filename)
end

local mt52 = { __index = _ENV }
local mt51 = { __index = _G }

-- @return a coroutine function
function slt2.render_co(t, env)
	local f
	if setfenv == nil then -- lua 5.2
		if env ~= nil then
			setmetatable(env, mt52)
		end
		f = assert(load(t.code, t.name, 't', env or _ENV))
	else -- lua 5.1
		if env ~= nil then
			setmetatable(env, mt51)
		end
		f = setfenv(t.code, env or _G)
	end
	return f
end

-- @return string
function slt2.render(t, env)
	local result = {}
	local co = coroutine.create(slt2.render_co(t, env))
	while coroutine.status(co) ~= 'dead' do
		local ok, chunk, indent = coroutine.resume(co)
		if not ok then
			error(chunk)
		end
		if indent then
			table.insert(result, indent_string(chunk, indent))
		else
			table.insert(result, chunk)
		end
	end
	return table.concat(result)
end

return slt2
