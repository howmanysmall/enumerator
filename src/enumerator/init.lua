-- enumerations in pure Luau
-- @docs https://roblox.github.io/enumerate/
-- documented changed functions

local t = require(script.t)

local ALREADY_USED_NAME_ERROR = "Already used %q as a value name in enum %q."
local ALREADY_USED_VALUE_ERROR = "Already used %q as a value in enum %q."
local INVALID_MEMBER_ERROR = "%q (%s) is not a valid member of %s"
local INVALID_VALUE_ERROR = "Couldn't cast value %q (%s) to enumerator %q"
local CANNOT_USE_ERROR = "Cannot use '%s' as a value"

local BLACKLISTED_VALUES = {
	cast = true,
	fromRawValue = true,
	getEnumeratorItems = true,
	isEnumValue = true,
}

local enumeratorTuple = t.tuple(
	t.string,
	t.union(
		t.array(t.string),
		t.keys(t.string)
	)
)

local function lockTable(tab, name)
	name = name or tostring(tab)

	local function protectedFunction(_, key)
		error(string.format(
			INVALID_MEMBER_ERROR,
			tostring(key),
			typeof(key),
			tostring(name)
		))
	end

	return setmetatable(tab, {
		__index = protectedFunction,
		__newindex = protectedFunction,
	})
end

--[[**
	Creates a new enumeration.
	@param [t:string] enumName The unique name of the enumeration.
	@param [t:union<t:array<t:string>, t:keys<t:string>>] enumValues The values of the enumeration.
	@returns [t:userdata] a new enumeration
**--]]
local function enumerator(enumName, enumValues)
	assert(enumeratorTuple(enumName, enumValues))

	local enum = newproxy(true)
	local internal = {}
	local rawValues = {}
	local totalEnums = 0

	function internal.fromRawValue(rawValue)
		return rawValues[rawValue]
	end

	function internal.isEnumValue(value)
		if typeof(value) ~= "userdata" then
			return false
		end

		for _, enumValue in pairs(internal) do
			if enumValue == value then
				return true
			end
		end

		return false
	end

	--[[**
		This function will cast values to the appropriate enumerator. This behaves like a type checker from t, except it returns the value if it was found.
		@param [t:any] value The value you want to cast.
		@returns [t:tuple<t:union<t:literal<false>, enumerator>, t:optional<t:string>>] Either returns the appropriate enumeration if found or false and an error message if it couldn't find it.
	**--]]
	function internal.cast(value)
		if internal.isEnumValue(value) then
			return value
		end

		local foundEnumerator = rawValues[value]
		if foundEnumerator ~= nil then
			return foundEnumerator
		else
			return false, string.format(
				INVALID_VALUE_ERROR,
				tostring(value),
				typeof(value),
				tostring(enum)
			)
		end
	end

	--[[**
		Returns an array of the enumerator items.
		@returns [t:array] An array of the items.
	**--]]
	function internal.getEnumeratorItems()
		local enumItems = table.create(totalEnums)
		local length = 0

		for _, value in pairs(rawValues) do
			length += 1
			enumItems[length] = value
		end

		return enumItems
	end

	if enumValues[1] then
		for _, valueName in ipairs(enumValues) do
			assert(not BLACKLISTED_VALUES[valueName], string.format(CANNOT_USE_ERROR, tostring(valueName)))
			assert(internal[valueName] == nil, string.format(ALREADY_USED_NAME_ERROR, valueName, enumName))
			assert(rawValues[valueName] == nil, string.format(ALREADY_USED_VALUE_ERROR, valueName, enumName))

			local value = newproxy(true)
			local metatable = getmetatable(value)
			local valueString = string.format("%s.%s", enumName, valueName)

			function metatable:__tostring()
				return valueString
			end

			metatable.__index = lockTable({
				name = valueName,
				type = enum,
				value = valueName,
				rawName = function()
					return valueName
				end,

				rawType = function()
					return enum
				end,

				rawValue = function()
					return valueName
				end,
			})

			internal[valueName] = value
			rawValues[valueName] = value
			totalEnums += 1
		end
	else
		for valueName, rawValue in pairs(enumValues) do
			assert(not BLACKLISTED_VALUES[valueName], string.format(CANNOT_USE_ERROR, tostring(valueName)))
			assert(internal[valueName] == nil, string.format(ALREADY_USED_NAME_ERROR, valueName, enumName))
			assert(rawValues[valueName] == nil, string.format(ALREADY_USED_VALUE_ERROR, valueName, enumName))

			local value = newproxy(true)
			local metatable = getmetatable(value)
			local valueString = string.format("%s.%s", enumName, valueName)

			function metatable:__tostring()
				return valueString
			end

			metatable.__index = lockTable({
				name = valueName,
				type = enum,
				value = rawValue,
				rawName = function()
					return valueName
				end,

				rawType = function()
					return enum
				end,

				rawValue = function()
					return rawValue
				end,
			})

			internal[valueName] = value
			rawValues[rawValue] = value
			totalEnums += 1
		end
	end

	local metatable = getmetatable(enum)
	metatable.__index = lockTable(internal, enumName)

	function metatable:__tostring()
		return enumName
	end

	return enum
end

return enumerator
