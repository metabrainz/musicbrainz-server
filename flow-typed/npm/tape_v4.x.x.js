// flow-typed signature: d8729919aecb7f7dee0289098715064e
// flow-typed version: dd3f7702d9/tape_v4.x.x/flow_>=v0.104.x

/* eslint-disable  */

declare type tape$TestOpts = {
  skip: boolean,
  timeout?: number,
  ...
} | {
  skip?: boolean,
  timeout: number,
  ...
};


declare type tape$TestCb = (t: tape$Context) => unknown;
declare type tape$TestFn = (a: string | tape$TestOpts | tape$TestCb, b?: tape$TestOpts | tape$TestCb, c?: tape$TestCb) => void;

declare interface tape$Context {
  fail(msg?: string): void,
  pass(msg?: string): void,

  error(err: unknown, msg?: string): void,
  ifError(err: unknown, msg?: string): void,
  ifErr(err: unknown, msg?: string): void,
  iferror(err: unknown, msg?: string): void,

  ok(value: unknown, msg?: string): void,
  true(value: unknown, msg?: string): void,
  assert(value: unknown, msg?: string): void,

  notOk(value: unknown, msg?: string): void,
  false(value: unknown, msg?: string): void,
  notok(value: unknown, msg?: string): void,

  // equal + aliases
  equal(actual: unknown, expected: unknown, msg?: string): void,
  equals(actual: unknown, expected: unknown, msg?: string): void,
  isEqual(actual: unknown, expected: unknown, msg?: string): void,
  is(actual: unknown, expected: unknown, msg?: string): void,
  strictEqual(actual: unknown, expected: unknown, msg?: string): void,
  strictEquals(actual: unknown, expected: unknown, msg?: string): void,

  // notEqual + aliases
  notEqual(actual: unknown, expected: unknown, msg?: string): void,
  notEquals(actual: unknown, expected: unknown, msg?: string): void,
  notStrictEqual(actual: unknown, expected: unknown, msg?: string): void,
  notStrictEquals(actual: unknown, expected: unknown, msg?: string): void,
  isNotEqual(actual: unknown, expected: unknown, msg?: string): void,
  isNot(actual: unknown, expected: unknown, msg?: string): void,
  not(actual: unknown, expected: unknown, msg?: string): void,
  doesNotEqual(actual: unknown, expected: unknown, msg?: string): void,
  isInequal(actual: unknown, expected: unknown, msg?: string): void,

  // deepEqual + aliases
  deepEqual(actual: unknown, expected: unknown, msg?: string): void,
  deepEquals(actual: unknown, expected: unknown, msg?: string): void,
  isEquivalent(actual: unknown, expected: unknown, msg?: string): void,
  same(actual: unknown, expected: unknown, msg?: string): void,

  // notDeepEqual
  notDeepEqual(actual: unknown, expected: unknown, msg?: string): void,
  notEquivalent(actual: unknown, expected: unknown, msg?: string): void,
  notDeeply(actual: unknown, expected: unknown, msg?: string): void,
  notSame(actual: unknown, expected: unknown, msg?: string): void,
  isNotDeepEqual(actual: unknown, expected: unknown, msg?: string): void,
  isNotDeeply(actual: unknown, expected: unknown, msg?: string): void,
  isNotEquivalent(actual: unknown, expected: unknown, msg?: string): void,
  isInequivalent(actual: unknown, expected: unknown, msg?: string): void,

  // deepLooseEqual
  deepLooseEqual(actual: unknown, expected: unknown, msg?: string): void,
  looseEqual(actual: unknown, expected: unknown, msg?: string): void,
  looseEquals(actual: unknown, expected: unknown, msg?: string): void,

  // notDeepLooseEqual
  notDeepLooseEqual(actual: unknown, expected: unknown, msg?: string): void,
  notLooseEqual(actual: unknown, expected: unknown, msg?: string): void,
  notLooseEquals(actual: unknown, expected: unknown, msg?: string): void,

  throws(fn: Function, expected?: RegExp | Function, msg?: string): void,
  doesNotThrow(fn: Function, expected?: RegExp | Function, msg?: string): void,

  timeoutAfter(ms: number): void,

  skip(msg?: string): void,
  plan(n: number): void,
  onFinish(fn: Function): void,
  end(): void,
  comment(msg: string): void,
  test: tape$TestFn,
}


declare module 'tape' {
  declare type TestHarness = Tape;
  declare type StreamOpts = { objectMode?: boolean, ... };

  declare type Tape = {
    (a: string | tape$TestOpts | tape$TestCb, b?: tape$TestCb | tape$TestOpts, c?: tape$TestCb, ...rest: Array<void>): void,
    test: tape$TestFn,
    skip: (name: string, cb?: tape$TestCb) => void,
    createHarness: () => TestHarness,
    createStream: (opts?: StreamOpts) => stream$Readable,
    only: (a: string | tape$TestOpts | tape$TestCb, b?: tape$TestCb | tape$TestOpts, c?: tape$TestCb, ...rest: Array<void>) => void,
    ...
  };

  declare module.exports: Tape;
}
