//I'm really sorry if you're looking at this
type FakeEnum = {};
type EnumeratorValues = ReadonlyArray<string> | { [key: string]: unknown };

type ArrayElementType<T> = T extends ReadonlyArray<infer U> ? U : never;

type LiteralToEnumeration<T extends EnumeratorValues> = {
	readonly [key in ArrayElementType<T>]: FakeEnum;
};

/**
 * 	Creates a new enumeration
 * @param name The unique name of the enumeration
 * @param values The values of the enumeration
 * @returns a new enumeration
 */
declare function enumerator<T extends EnumeratorValues>(
	name: string,
	values: T,
): T extends ReadonlyArray<string> ? LiteralToEnumeration<T> : Readonly<T>;

export = enumerator;
