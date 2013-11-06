--[[API

Generates API data structures to be used by templates.

API.ClassData ( className )

	Generates data for a given class. Here is the structure of the returned
	value, as described by Go syntax (returns Class):

	// The entire data structure needed by the class template.
	type Class struct {
		Name         string                 // name of the class
		Icon         ClassIcon              // class's icon index
		Superclasses []ClassIconPair        // list of classes that the class inherits from
		Subclasses   []ClassIconPair        // sorted by ClassIconPair.Class
		Tags         map[string]bool        // Tags given to the class
		TagList      []string               // sorted; excludes preliminary and deprecated tags
		Members      []MemberType           // List of members per member type
		MemberSet    map[string]interface{} // Member names paired with Property, Function, YieldFunction, Event, or Callback
		Enums        []Enum                 // sorted by Enum.Name
	}

	// Represents the index of an icon on the explorer icon sheet.
	type ClassIcon int

	// Represents the index of an icon on the object browser icon sheet.
	type MemberIcon int

	// A class name paired with an icon.
	type ClassIconPair struct {
		Class string
		Icon  ClassIcon
	}

	// Represents the members of a class for a single member type.
	type MemberType struct {
		Type       string        // the member type
		TypePlural string        // plural form of the member type
		List       []interface{} // Property, Function, YieldFunction, Event, Callback
		Inherited  []Inherited   // a list of inherited members
		HasTags    bool          // whether at least one member has tags
	}

	// A single property member.
	type Property struct {
		Icon      MemberIcon      // the member's icon index
		Name      string          // the name of the member
		Type      string          // the member type
		ValueType string          // the property's value type
		Tags      map[string]bool // tags given to the member
		TagList   []string        // tags in sorted list form
	}

	// A single function member.
	type Function struct {
		Icon       MemberIcon      // the member's icon index
		Name       string          // the name of the member
		Type       string          // the member type
		ReturnType string          // the type returned by the function
		Arguments  []Argument      // a list of the function's arguments
		Tags       map[string]bool // tags given to the member
		TagList    []string        // tags in sorted list form
	}

	// A single yield function member.
	type YieldFunction Function

	// A single event member.
	type Event struct {
		Icon       MemberIcon      // the member's icon index
		Name       string          // the name of the member
		Type       string          // the member type
		Parameters []Argument      // a list of the event's parameters
		Tags       map[string]bool // tags given to the member
		TagList    []string        // tags in sorted list form
	}

	// A single callback member.
	type Callback struct {
		Icon       MemberIcon      // the member's icon index
		Name       string          // the name of the member
		Type       string          // the member type
		ReturnType string          // the expected return value type of the callback
		Parameters []Argument      // a list of the callback's parameters
		Tags       map[string]bool // tags given to the member
		TagList    []string        // tags in sorted list form
	}

	// A single argument or parameter
	type Argument struct {
		Type    string // the argument's value type
		Name    string // the argument's name
		Default string // a string representation of the argument's default value; nullable
	}

	// Represents the amount of members of a given type that a given class
	// inherits from the indicated class.
	type Inherited struct {
		Class  string // the class inherited from
		Amount int    // the number of members inherited
	}

	// A single enum.
	type Enum struct {
		Name  string     // the name of the enum
		Items []EnumItem // a list of the enum's items, sorted by value
	}

	// A single enum item.
	type EnumItem struct {
		Name  string // the item's name
		Value int    // the item's value
	}

API.ClassTree ( )

	Generates a tree representing the inheritance relationship between every
	class. Here is the structure of the returned value, as described by Go
	syntax (returns TreeNodeList):

	// A list of tree nodes.
	type TreeNodeList []TreeNode

	// Represents a single node in the tree.
	type TreeNode struct {
		Class string       // the class name
		Icon  ClassIcon    // the class icon
		List  TreeNodeList // a list of classes that inherit the class
	}

API.ClassIconIndex ( className )

	Returns the icon index for a given class. Returns 0 if an index does not
	exist for the class.

API.MemberIconIndex ( memberStruct )

	Returns the icon index for a given member. `memberStruct` requires a
	`type` field, which is the member type, and a `tags` field, which is a set
	of strings.

]]

local APIDump,ExplorerIndex = unpack(require 'FetchAPI')

-- The order in which member types will be displayed
local MemberTypeOrder = {
	Property      = 1;
	Function      = 2;
	YieldFunction = 3;
	Event         = 4;
	Callback      = 5;
}

-- Maps to the plural form of a member type
local MemberTypePlural = {
	Callback      = 'Callbacks';
	Event         = 'Events';
	Function      = 'Functions';
	Property      = 'Properties';
	YieldFunction = 'YieldFunctions';
}

-- Maps a member type and state to an index on the object browser icon sheet
local MemberIconIndex = {
	              --  Default, Protected, Locked
	Property      = {       6,         7,     14 };
	Function      = {       4,         5,     13 };
	YieldFunction = {       4,         5,     13 };
	Event         = {      11,        12,     15 };
	Callback      = {      16,        16,     16 };
}

-- Maps member tags to one of the states in the MemberIconIndex table
local MemberTagState = {
	RobloxPlaceSecurity  = 3; -- Locked
	LocalUserSecurity    = 2; -- Protected
	WritePlayerSecurity  = 2; -- Protected
	RobloxScriptSecurity = 2; -- Protected
	RobloxSecurity       = 2; -- Protected
}

local function classIconIndex(class)
	return ExplorerIndex[class] or 0
end

local function memberIconIndex(member)
	local ref = 1
	for tag,state in pairs(MemberTagState) do
		if member.tags[tag] then
			ref = state
			break
		end
	end
	return MemberIconIndex[member.type][ref]
end

local API = {}

function API.ClassData(className)
	local classLookup = {}
	local memberSet = {}
	local memberTypeLookup = {}
	local enumLookup = {}

	for i = 1,#APIDump do
		local item = APIDump[i]

		local tags = {}
		local tagList = {}
		for tag in pairs(item.tags) do
			tags[tag] = true
			if tag ~= 'preliminary' and tag ~='deprecated' then
				tagList[#tagList+1] = tag
			end
		end
		table.sort(tagList)
		local new = {}
		new.Tags = tags
		new.TagList = tagList
		for k,v in pairs(item) do
			if k ~= 'tags' and k ~= 'type' then
				new[k] = v
			end
		end

		if item.type == 'Class' then
			if not memberTypeLookup[item.Name] then
				memberTypeLookup[item.Name] = {}
			end
			classLookup[item.Name] = new
		elseif item.Class then
			local memberTypes = memberTypeLookup[item.Class]
			if not memberTypes then
				memberTypes = {}
				memberTypeLookup[item.Class] = memberTypes
			end

			local memberType = memberTypes[item.type]
			if not memberType then
				memberType = {
					List = {};
					Inherited = {};
					HasTags = false;
					Type = item.type;
					TypePlural = MemberTypePlural[item.type];
				}
				memberTypes[item.type] = memberType
			end

			new.Type = item.type
			new.Icon = memberIconIndex(item)
			if #tagList > 0 then
				memberType.HasTags = true
			end
			table.insert(memberType.List,new)

			if item.Class == className then
				memberSet[item.Name] = new
			end
		elseif item.type == 'Enum' then
			enumLookup[item.Name] = {}
		elseif item.type == 'EnumItem' then
			local enum = enumLookup[item.Enum]
			if not enum then
				enum = {}
				enumLookup[item.Name] = enum
			end
			enum[#enum+1] = new
		end
	end

	local class = {
		Name = className;
		Icon = classIconIndex(className);
		Tags = classLookup[className].Tags;
		TagList = classLookup[className].TagList;
		Members = {};
		MemberSet = memberSet;
		Enums = {};
	}

	-- add subclasses
	local subclasses = {}
	for name,class in pairs(classLookup) do
		if class.Superclass == className then
			subclasses[#subclasses+1] = {
				Icon = classIconIndex(name);
				Class = name;
			}
		end
	end
	table.sort(subclasses,function(a,b)
		return a.Class < b.Class
	end)
	class.Subclasses = subclasses

	local memberTypes = memberTypeLookup[className]

	do
		local superclasses = {}
		class.Superclasses = superclasses
		local name = className
		while true do
			name = classLookup[name].Superclass
			if not name then
				break
			end
			-- superclasses
			table.insert(superclasses,{
				Icon = classIconIndex(name);
				Class = name;
			})

			-- add inherited members
			if memberTypeLookup[name] then
				for superTypeName,superMemberType in pairs(memberTypeLookup[name]) do
					if not memberTypes[superTypeName] then
						memberTypes[superTypeName] = {
							List = {};
							Inherited = {};
							HasTags = false;
							Type = superTypeName;
							TypePlural = MemberTypePlural[superTypeName];
						}
					end

					table.insert(memberTypes[superTypeName].Inherited,{
						Class = name;
						Amount = #superMemberType.List;
					})
				end
			end
		end
	end

	local function sort(a,b)
		local da = a.Tags.deprecated
		local db = b.Tags.deprecated
		if da and db or not da and not db then
			return a.Name < b.Name
		else
			-- put deprecated items at the end of the list
			return db
		end
	end

	local enums = class.Enums
	local enumSet = {}
	for typeName,memberType in pairs(memberTypes) do
		local list = memberType.List

		-- sort list of members
		table.sort(list,sort)

		-- gather enums
		if typeName == 'Property' then
			for i = 1,#list do
				local name = list[i].ValueType
				if enumLookup[name] then
					enumSet[name] = enumLookup[name]
				end
			end
		elseif typeName == 'Function' or typeName == 'YieldFunction' then
			for i = 1,#list do
				local name = list[i].ReturnType
				if enumLookup[name] then
					enumSet[name] = enumLookup[name]
				end

				local args = list[i].Arguments
				for i = 1,#args do
					local name = args[i].Type
					if enumLookup[name] then
						enumSet[name] = enumLookup[name]
					end
				end
			end
		elseif typeName == 'Event' then
			for i = 1,#list do
				local args = list[i].Parameters
				for i = 1,#args do
					local name = args[i].Type
					if enumLookup[name] then
						enumSet[name] = enumLookup[name]
					end
				end
			end
		elseif typeName == 'Callback' then
			for i = 1,#list do
				local name = list[i].ReturnType
				if enumLookup[name] then
					enumSet[name] = enumLookup[name]
				end

				local args = list[i].Parameters
				for i = 1,#args do
					local name = args[i].Type
					if enumLookup[name] then
						enumSet[name] = enumLookup[name]
					end
				end
			end
		end
	end

	for name,items in pairs(enumSet) do
		enums[#enums+1] = {
			Name = name;
			Items = items;
		}
	end

	-- sort enums by name
	table.sort(enums,function(a,b)
		return a.Name < b.Name
	end)

	for i = 1,#enums do
		-- sort enum items by value
		table.sort(enums[i].Items,function(a,b)
			return a.Value < b.Value
		end)
	end

	-- add list of member types
	for _,memberType in pairs(memberTypes) do
		table.insert(class.Members,memberType)
	end

	-- sort member types
	table.sort(class.Members,function(a,b)
		return MemberTypeOrder[a.Type] < MemberTypeOrder[b.Type]
	end)

	return class
end

function API.ClassTree()
	local classes = {}
	for i = 1,#APIDump do
		local item = APIDump[i]
		if item.type == 'Class' then
			classes[item.Name] = item.Superclass or false
		end
	end

	local sorted = {}
	for k in pairs(classes) do
		sorted[#sorted+1] = k
	end
	table.sort(sorted)

	local list = {}

	local function r(root,t)
		for i = 1,#sorted do
			local child = sorted[i]
			if classes[child] == root then
				local q = {}
				t[#t+1] = q
				q.Class = child
				q.Icon = classIconIndex(child)
				q.List = {}
				r(child,q.List)
			end
		end
	end

	r(false,list)

	return list
end

API.ClassIconIndex = classIconIndex
API.MemberIconIndex = memberIconIndex

return API
