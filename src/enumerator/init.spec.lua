type Dictionary<Value> = {[string]: Value}
type DescribeFunction = (Dictionary<any>?) -> nil

type Expectation = {
	never: {
		to: {
			be: {
				a: (string) -> Expectation,
				an: (string) -> Expectation,
				near: (number, number?) -> Expectation,
				ok: () -> Expectation,
			},

			equal: (any) -> Expectation,
			throw: (string?) -> Expectation,
		},
	},

	to: {
		be: {
			a: (string) -> Expectation,
			an: (string) -> Expectation,
			near: (number, number?) -> Expectation,
			ok: () -> Expectation,
		},

		equal: (any) -> Expectation,
		throw: (string?) -> Expectation,
	},
}

type describe = (string, DescribeFunction) -> nil
type expect = (any) -> Expectation
type it = describe
type describeSKIP = (string) -> nil

return function()
	local enumerator = require(script.Parent)
	local t = require(script.Parent.t)

	-- describe = describe :: describe
	-- expect = expect :: expect
	-- it = it :: it
	-- describeSKIP = describeSKIP :: describeSKIP
	-- itSKIP = itSKIP :: it

	describe("Enum creation", function()
		local MyEnum = enumerator("MyEnum", {"ValueOne", "ValueTwo", "ValueThree"})

		it("should exist", function()
			expect(MyEnum).to.be.ok()
		end)

		it("should return the correct name when called with tostring", function()
			expect(tostring(MyEnum)).to.equal("MyEnum")
		end)

		it("should be locked", function()
			expect(function()
				MyEnum.ValueOne = "ValueTwo"
			end).to.throw()
		end)

		it("should error when accessing an invalid value", function()
			expect(function()
				local _ = MyEnum.ValueFour
			end).to.throw()
		end)

		it("should have values that can be compared for equality", function()
			expect(MyEnum.ValueOne).to.equal(MyEnum.ValueOne)
			expect(MyEnum.ValueOne == MyEnum.ValueTwo).to.equal(false)
		end)

		it("should use userdata for entries", function()
			expect(typeof(MyEnum.ValueOne)).to.equal("userdata")
			expect(typeof(MyEnum.ValueTwo)).to.equal("userdata")
		end)

		it("should have values return the correct name", function()
			expect(tostring(MyEnum.ValueOne)).to.equal("MyEnum.ValueOne")
		end)
	end)

	describe("Enum rawValue/value", function()
		local MyEnum = enumerator("MyValueEnum", {"ValueOne", "ValueTwo"})

		-- Checking `rawValue` type
		it("should have values with correct rawValue types", function()
			expect(type(MyEnum.ValueOne.rawValue())).to.equal("string")
			expect(type(MyEnum.ValueTwo.rawValue())).to.equal("string")
		end)

		-- Checking `value` type
		it("should have values with correct value types", function()
			expect(type(MyEnum.ValueOne.value)).to.equal("string")
			expect(type(MyEnum.ValueTwo.value)).to.equal("string")
		end)

		-- Checking `rawValue`
		it("should have values with correct rawValues", function()
			expect(MyEnum.ValueOne.rawValue()).to.equal("ValueOne")
			expect(MyEnum.ValueTwo.rawValue()).to.equal("ValueTwo")
		end)

		-- Checking `value`
		it("should have values with correct value", function()
			expect(MyEnum.ValueOne.value).to.equal("ValueOne")
			expect(MyEnum.ValueTwo.value).to.equal("ValueTwo")
		end)
	end)

	describe("Enum rawType/type", function()
		local MyEnum = enumerator("MyTypeEnum", {"ValueOne", "ValueTwo"})

		-- Checking `rawType` type
		it("should have values with correct rawType types", function()
			expect(typeof(MyEnum.ValueOne.rawType())).to.equal("userdata")
			expect(typeof(MyEnum.ValueTwo.rawType())).to.equal("userdata")
		end)

		-- Checking `type` type
		it("should have values with correct type types", function()
			expect(typeof(MyEnum.ValueOne.type)).to.equal("userdata")
			expect(typeof(MyEnum.ValueTwo.type)).to.equal("userdata")
		end)

		-- Checking `rawType`
		it("should have values with correct rawType types", function()
			expect(MyEnum.ValueOne.rawType()).to.equal(MyEnum)
			expect(MyEnum.ValueTwo.rawType()).to.equal(MyEnum)
		end)

		-- Checking `type`
		it("should have values with correct type types", function()
			expect(MyEnum.ValueOne.type).to.equal(MyEnum)
			expect(MyEnum.ValueTwo.type).to.equal(MyEnum)
		end)
	end)

	describe("Enum rawName/name", function()
		local MyEnum = enumerator("MyNameEnum", {"ValueOne", "ValueTwo"})

		-- Checking `rawName` type
		it("should have values with correct rawName types", function()
			expect(type(MyEnum.ValueOne.rawName())).to.equal("string")
			expect(type(MyEnum.ValueTwo.rawName())).to.equal("string")
		end)

		-- Checking `name` type
		it("should have values with correct name types", function()
			expect(type(MyEnum.ValueOne.name)).to.equal("string")
			expect(type(MyEnum.ValueTwo.name)).to.equal("string")
		end)

		-- Checking `rawName`
		it("should have values with correct rawName types", function()
			expect(MyEnum.ValueOne.rawName()).to.equal("ValueOne")
			expect(MyEnum.ValueTwo.rawName()).to.equal("ValueTwo")
		end)

		-- Checking `name`
		it("should have values with correct name types", function()
			expect(MyEnum.ValueOne.name).to.equal("ValueOne")
			expect(MyEnum.ValueTwo.name).to.equal("ValueTwo")
		end)
	end)

	describe("Enum.fromRawValue", function()
		local MyEnum = enumerator("MyRawValueEnum", {"ValueOne", "ValueTwo"})

		it("should return the correct value from a rawValue", function()
			expect(MyEnum.fromRawValue("ValueOne")).to.equal(MyEnum.ValueOne)
			expect(MyEnum.fromRawValue("ValueTwo")).to.equal(MyEnum.ValueTwo)
		end)
	end)

	describe("Enum.isEnumValue", function()
		local MyEnum = enumerator("MyBooleanEnum", {"ValueOne", "ValueTwo"})

		it("should detect whether a value is an enum value", function()
			expect(MyEnum.isEnumValue(MyEnum.ValueOne)).to.equal(true)
			expect(MyEnum.isEnumValue("ValueOne")).to.equal(false)

			expect(MyEnum.isEnumValue(MyEnum.ValueTwo)).to.equal(true)
			expect(MyEnum.isEnumValue("ValueTwo")).to.equal(false)
		end)
	end)

	describe("Enum.cast", function()
		local MyCastEnum = enumerator("MyCastEnum", {"ValueOne", "ValueTwo"})
		it("should return the enumeration if found from a value", function()
			expect(MyCastEnum.cast("ValueOne")).to.equal(MyCastEnum.ValueOne)
			expect(MyCastEnum.cast("ValueTwo")).to.equal(MyCastEnum.ValueTwo)
		end)

		it("should return the enumeration if found from an enumeration", function()
			expect(MyCastEnum.cast(MyCastEnum.ValueOne)).to.equal(MyCastEnum.ValueOne)
			expect(MyCastEnum.cast(MyCastEnum.ValueTwo)).to.equal(MyCastEnum.ValueTwo)
		end)

		it("should return false and an error message if not found", function()
			local value, errorMessage = MyCastEnum.cast("ValueThree")
			expect(value).to.equal(false)
			expect(errorMessage).to.be.a("string")
		end)

		it("should error if put into an assert if not found", function()
			expect(function()
				assert(MyCastEnum.cast("ValueThree"))
			end).to.throw()
		end)
	end)

	describe("Enum.getEnumeratorItems", function()
		local MyListEnum = enumerator("MyListEnum", {"ValueOne", "ValueTwo"})
		it("should return an array", function()
			expect(MyListEnum.getEnumeratorItems()).to.be.a("table")
			expect(t.array(t.any)(MyListEnum.getEnumeratorItems())).to.equal(true)
		end)

		it("should contain every value", function()
			for _, enum in ipairs(MyListEnum.getEnumeratorItems()) do
				expect(MyListEnum.isEnumValue(enum)).to.equal(true)
			end
		end)
	end)

	it("should error when creating an enum with a non-string name", function()
		expect(function()
			enumerator(1, {"ValueOne"})
		end).to.throw()
	end)

	it("should error when creating an enum with duplicate values", function()
		expect(function()
			enumerator("MyCoolEnum", {"ValueOne", "ValueOne"})
		end).to.throw()
	end)

	it("should error when creating an enum with disallowed values", function()
		expect(function()
			enumerator("MyUncoolEnum", {"cast", "Cast"})
		end).to.throw()
	end)
end