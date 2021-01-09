//I'm really sorry if you're looking at this
// Credit to Xuleos and Osyris for the typing.
interface FakeEnum<T> {
	value: T;
	rawValue(): T;
}

interface SharedEnumerationMethods {
	isEnumValue(value: unknown): boolean;
}

type LiteralEnumeration<T extends string> = {
	readonly [K in T]: FakeEnum<string>;
} & {
	fromRawValue<K extends T>(key: K): string;
} & SharedEnumerationMethods;

type DictionaryEnumeration<T> = { readonly [K in keyof T]: FakeEnum<T[K]> } & {
	fromRawValue<K extends keyof T>(key: K): T[K];
} & SharedEnumerationMethods;

interface enumeratorConstructor {
	/**
	 * Creates a new enumeration
	 * @param name The unique name of the enumeration
	 * @param values The values of the enumeration
	 * @returns a new enumeration
	 */
	<T extends string>(name: string, values: ReadonlyArray<T>): LiteralEnumeration<T>;
	<T extends { [key: string]: unknown }>(name: string, values: T): DictionaryEnumeration<T>;

	/**
	 * Creates a new enumeration
	 * @param name The unique name of the enumeration
	 * @param values The values of the enumeration
	 * @returns a new enumeration
	 */
	enumerator<T extends string>(this: void, name: string, values: ReadonlyArray<T>): LiteralEnumeration<T>;
	enumerator<T extends { [key: string]: unknown }>(this: void, name: string, values: T): DictionaryEnumeration<T>;

	/**
	 * Creates a function for the passed enumerator that will cast values to the appropriate enumerator.
	 * This behaves like a type checker from `t`, except it returns the value if it was found.
	 * @param castFromEnumerator The enumerator you are casting from.
	 * @returns A function that takes a value and returns the appropriate enumeration if found or false and an error message if it couldn't find it.
	 */
	castEnumerator<T extends { [key: string]: unknown }>(
		this: undefined,
		castFromEnumerator: DictionaryEnumeration<T>,
	): (value: unknown) => value is T;
	castEnumerator<T extends string>(
		this: undefined,
		castFromEnumerator: LiteralEnumeration<T>,
	): (value: unknown) => value is T;
}

declare const enumerator: enumeratorConstructor;
export = enumerator;
