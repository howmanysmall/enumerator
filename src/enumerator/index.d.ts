//I'm really sorry if you're looking at this
interface FakeEnum<T> {
	value: T;
	rawValue(): T;
}

interface SharedEnumerationMethods {
	isEnumValue(value: unknown): boolean;
}

type AcceptableEnumeratorValues = ReadonlyArray<string> | { [key: string]: unknown };

type ArrayElementType<T> = T extends ReadonlyArray<infer U> ? U : never;

type LiteralEnumeration<T extends AcceptableEnumeratorValues> = {
	readonly [K in ArrayElementType<T>]: FakeEnum<string>;
} & {
	fromRawValue<K extends ArrayElementType<T>>(key: K): string;
} & SharedEnumerationMethods;

type DictionaryEnumeration<T> = {
	readonly [K in keyof T]: FakeEnum<T[K]>;
} & {
	fromRawValue<K extends keyof T>(key: K): T[K];
} & SharedEnumerationMethods;
/**
 * 	Creates a new enumeration
 * @param name The unique name of the enumeration
 * @param values The values of the enumeration
 * @returns a new enumeration
 */
declare function enumerator<T extends AcceptableEnumeratorValues>(
	name: string,
	values: T,
): T extends ReadonlyArray<string> ? LiteralEnumeration<T> : DictionaryEnumeration<T>;

export = enumerator;
