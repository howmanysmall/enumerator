return function()
	local enumerator = require(script.Parent)

	describe("Enum creation", function()
		local MyEnum = enumerator("MyEnum", {"ValueOne", "ValueTwo", "ValueThree"})

		it("should exist", function()
			expect(MyEnum).to.be.ok()
		end)

		it("should return the correct name when called with tostring", function()
			expect(tostring(MyEnum)).to.be.equal("MyEnum")
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
		end)

		it("should have values with correct rawValue types", function()
			expect(typeof(MyEnum.ValueOne.rawValue())).to.equal("string")
		end)

		it("should have values with correct value types", function()
			expect(typeof(MyEnum.ValueOne.value)).to.equal("string")
		end)

		it("should have values return the correct name", function()
			expect(tostring(MyEnum.ValueOne)).to.equal("MyEnum.ValueOne")
		end)

		it("should have values with correct rawValues", function()
			expect(MyEnum.ValueOne.rawValue()).to.equal("ValueOne")
		end)

		it("should have values with correct value", function()
			expect(MyEnum.ValueOne.value).to.equal("ValueOne")
		end)

		it("should return the correct value from a rawValue", function()
			expect(MyEnum.fromRawValue("ValueOne")).to.equal(MyEnum.ValueOne)
		end)

		it("should detect whether a value is an enum value", function()
			expect(MyEnum.isEnumValue(MyEnum.ValueOne)).to.equal(true)
			expect(MyEnum.isEnumValue("ValueOne")).to.equal(false)
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

	describe("castEnumerator", function()
		local MyAwesomeEnum = enumerator("MyAwesomeEnum", {"ValueOne"})
		local castToMyAwesomeEnum = enumerator.castEnumerator(MyAwesomeEnum)

		it("should return the enumeration if found from a value", function()
			expect(castToMyAwesomeEnum("ValueOne")).to.equal(MyAwesomeEnum.ValueOne)
		end)

		it("should return the enumeration if found from an enumeration", function()
			expect(castToMyAwesomeEnum(MyAwesomeEnum.ValueOne)).to.equal(MyAwesomeEnum.ValueOne)
		end)

		it("should return false and an error message if not found", function()
			local value, errorMessage = castToMyAwesomeEnum("ValueTwo")
			expect(value).to.equal(false)
			expect(errorMessage).to.be.a("string")
		end)

		it("should error if put into an assert if not found", function()
			expect(function()
				assert(castToMyAwesomeEnum("ValueTwo"))
			end).to.throw()
		end)
	end)
end