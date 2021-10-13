-- enumerations in pure Luau

local t = require(script.t)

local ALREADY_USED_NAME_ERROR = "Already used %q as a value name in enum %q."
local ALREADY_USED_VALUE_ERROR = "Already used %q as a value in enum %q."
local CANNOT_USE_ERROR = "Cannot use '%s' as a value"
local INVALID_MEMBER_ERROR = "%q (%s) is not a valid member of %s"
local INVALID_VALUE_ERROR = "Couldn't cast value %q (%s) to enumerator %q"

local BLACKLISTED_VALUES = {
	cast = true,
	fromRawValue = true,
	getEnumeratorItems = true,
	getSortedEnumeratorItems = true,
	isEnumValue = true,
}

-- stylua: ignore
local enumeratorTuple = t.tuple(
	t.string,
	t.union(t.array(t.string), t.keys(t.string))
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

type EnumValues = {string} | {[string]: any}

export type EnumeratorItem<Value> = {
	name: string,
	type: EnumeratorObject<Value>,
	value: Value,

	rawName: () -> string,
	rawType: () -> EnumeratorObject<Value>,
	rawValue: () -> Value,
}

export type EnumeratorObject<Value> = {
	cast: (value: any) -> (EnumeratorItem<Value> | boolean, string?),
	fromRawValue: (rawValue: Value) -> EnumeratorItem<Value>?,
	getEnumeratorItems: () -> {EnumeratorItem<Value>},
	getSortedEnumeratorItems: () -> {EnumeratorItem<Value>},
	isEnumValue: (value: any) -> boolean,
}

local function sortByValue(a, b)
	return a.value < b.value
end

--[=[
	An EnumeratorItem is meant to represent a unique value.
	@interface EnumeratorItem
	@tag Enum
	@readonly
	.name string
	.type EnumeratorObject<Value>
	.value Value
	.rawName () -> string
	.rawType () -> EnumeratorObject<Value>
	.rawValue () -> Value
]=]

--[=[
	Creates a new `EnumeratorObject`.

	```lua
	local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})
	local Numbers = enumerator("Numbers", {
		One = 1;
		Two = 2;
		Three = 3;
	})
	```

	@param enumName string -- The name of the enumeration.
	@param enumValues {string} | {[string]: any} -- The values of the enumeration.
	@returns EnumeratorObject -- The new EnumeratorObject.
]=]
local function enumerator(enumName: string, enumValues: EnumValues)
	assert(enumeratorTuple(enumName, enumValues))

	local enum = newproxy(true)
	local internal = {}
	local rawValues = {}
	local totalEnums = 0

	--[=[
		Returns an `EnumeratorItem` from the calling `EnumeratorObject` if the `rawValue` exists in it.

		```lua
		local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})
		print(Fruit.fromRawValue("Apple")) -- Fruit.Apple
		print(Fruit.fromRawValue("Banana")) -- Fruit.Banana
		print(Fruit.fromRawValue("Anything")) -- nil
		```

		```lua
		local Numbers = enumerator("Numbers", {
			One = 1;
			Two = 2;
			Three = 3;
		})

		print(Numbers.fromRawValue(1)) -- Numbers.One
		print(Numbers.fromRawValue(2)) -- Numbers.Two
		print(Numbers.fromRawValue(4)) -- nil
		```

		@param rawValue any -- The raw value of the enum.
		@return EnumeratorItem? -- The `EnumeratorItem` if it was found.
	]=]
	function internal.fromRawValue(rawValue: any): EnumeratorItem<any>?
		return rawValues[rawValue]
	end

	--[=[
		Returns `true` only if the provided value is an `EnumeratorItem` that is a member of the calling `EnumeratorObject`.

		```lua
		local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})
		print(Fruit.isEnumValue(Fruit.Apple)) -- true
		print(Fruit.isEnumValue(Fruit.Banana)) -- true
		print(Fruit.isEnumValue(newproxy(false))) -- false
		print(Fruit.isEnumValue("Banana")) -- false
		```

		@param value any -- The value to check against.
		@return boolean -- True only if the passed value is an `EnumeratorItem` belonging to this `EnumeratorObject`.
	]=]
	function internal.isEnumValue(value: EnumeratorItem<any>): boolean
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

	--[=[
		This function will cast values to the appropriate `EnumeratorItem`. This behaves like a type checker from t, except it returns the value if it was found.

		```lua
		local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})

		print(Fruit.cast("Apple")) -- Fruit.Apple
		print(Fruit.cast("Banana")) -- Fruit.Banana
		assert(Fruit.cast("Carrot")) -- Errors with `Couldn't cast value "Carrot" (string) to enumerator "Fruit"`
		```

		@param value any -- The value you want to cast.
		@return false | EnumeratorItem -- `false` if this is not a valid EnumeratorItem, otherwise returns the correct EnumeratorItem.
		@return string? -- The error message if the value is not a valid EnumeratorItem.
	]=]
	function internal.cast(value: any): (boolean | EnumeratorItem<any>, string?)
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

	--[=[
		Gets all of the EnumeratorItems.

		```lua
		local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})
		print(Fruit.getEnumeratorItems())

		--[[
		{
			[1] = "Fruit.Apple",
			[2] = "Fruit.Grape",
			[3] = "Fruit.Orange",
			[4] = "Fruit.Banana"
		}
		]]
		```

		@return {EnumeratorItem} -- Returns the EnumeratorItems.
	]=]
	function internal.getEnumeratorItems(): {EnumeratorItem<any>}
		local enumItems = table.create(totalEnums)
		local length = 0

		for _, value in pairs(rawValues) do
			length += 1
			enumItems[length] = value
		end

		return enumItems
	end

	--[=[
		Gets the EnumeratorItems sorted by their `value` property.

		```lua
		local Fruit = enumerator("Fruit", {"Apple", "Banana", "Orange", "Grape"})
		print(Fruit.getSortedEnumeratorItems())

		--[[
		{
			[1] = "Fruit.Apple",
			[2] = "Fruit.Banana",
			[3] = "Fruit.Grape",
			[4] = "Fruit.Orange"
		}
		]]
		```

		@return {EnumeratorItem} -- Returns the sorted EnumeratorItems.
	]=]
	function internal.getSortedEnumeratorItems(): {EnumeratorItem<any>}
		local enumItems = table.create(totalEnums)
		local length = 0

		for _, value in pairs(rawValues) do
			length += 1
			enumItems[length] = value
		end

		table.sort(enumItems, sortByValue)
		return enumItems
	end

	local nextIndex = next(enumValues)
	if nextIndex == 1 then
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
				rawName = function(): string
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

-- If you wish to use the above types to define an enum, you can do it as such:
--[[

local enumerator = require("enumerator")
type EnumeratorItem<Value> = enumerator.EnumeratorItem<Value>

export type RunServiceEvent = {
	Heartbeat: EnumeratorItem<string>,
	RenderStepped: EnumeratorItem<string>,
	Stepped: EnumeratorItem<string>,
} & enumerator.EnumeratorObject<string>

local RunServiceEvent: RunServiceEvent = enumerator("RunServiceEvent", {"Heartbeat", "RenderStepped", "Stepped"}) :: RunServiceEvent
return RunServiceEvent

--]]

return enumerator
