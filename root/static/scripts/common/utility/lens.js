/*
 * @flow
 *
 * Copyright (C) 2017 Giulio Canti
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/*
 * The general lens implementation was copied from
 * https://github.com/gcanti/monocle-ts/tree/d1ebe6b with heavy modifications.
 */

import assign from 'lodash/assign';

const hasOwnProperty = Object.prototype.hasOwnProperty;

type MapT = {+[string]: *};

function objectAssign<T: MapT, K: $Keys<T>>(
  source: T,
  prop: K,
  value: $ElementType<T, K>,
): T {
  const copy = {};
  for (const key in source) {
    if (hasOwnProperty.call(source, key)) {
      copy[key] = key === prop ? value : source[key];
    }
  }
  return ((copy: any): T);
}

function arrayAssign<T: Array<*>, I: number>(
  source: T,
  index: I,
  value: $ElementType<T, I>,
): T {
  const copy = source.slice(0);
  copy[index] = value;
  return copy;
}

/*
 * Laws:
 * 1. get(set(a, s)) = a
 * 2. set(get(s), s) = s
 * 3. set(a, set(a, s)) = set(a, s)
 */

export interface Lens<S, A> {
  get(s: S): A;
  set(a: A): (s: S) => S;
}

export function prop<
  S: *,
  P: $Keys<S>,
  A: $ElementType<S, P>
>(prop: P): Lens<S, A> {
  return {get: s => s[prop], set: a => s => objectAssign(s, prop, a)};
}

export function index<
  S: *,
  I: number,
  A: $ElementType<S, I>
>(i: I): Lens<S, A> {
  return {get: s => s[i], set: a => s => arrayAssign(s, i, a)};
}

export function maybeProp<
  S: *,
  P: $Keys<S>,
  A: $ElementType<$NonMaybeType<S>, P>
>(prop: P, getDefault: (s: S) => A): Lens<S, A> {
  return {
    get: s => hasOwnProperty.call(s, prop) ? s[prop] : getDefault(s),
    set: a => s => objectAssign(s, prop, a),
  };
}

export function maybeIndex<
  S: *,
  I: number,
  A: $ElementType<$NonMaybeType<S>, I>
>(i: I, getDefault: (s: S) => A): Lens<S, A> {
  return {
    get: s => i >= 0 && i < s.length ? s[i] : getDefault(s),
    set: a => s => arrayAssign(s, i, a),
  };
}

export function set<S: *, A>(lens: Lens<S, A>, a: A, s: S): S {
  return lens.set(a)(s);
}

export function update<S: *, A>(lens: Lens<S, A>, f: (a: A) => A, s: S): S {
  return lens.set(f(lens.get(s)))(s);
}

function _merge<T: MapT>(a: T, b: T): T {
  return assign({}, a, b);
}

export function merge<S: *, A: MapT>(lens: Lens<S, A>, values: A, s: S): S {
  return lens.set(_merge(lens.get(s), values))(s);
}

export function deleteIndex<S: *, A: Array<*>>(
  lens: Lens<S, A>,
  i: number,
  s: S,
): S {
  const a = lens.get(s).slice(0);
  a.splice(i, 1);
  return lens.set(a)(s);
}

export function compose2<S: *, A, B>(
  sa: Lens<S, A>,
  ab: Lens<A, B>,
): Lens<S, B> {
  return {
    get: s => ab.get(sa.get(s)),
    set: b => s => sa.set(ab.set(b)(sa.get(s)))(s),
  };
}

export function compose3<S: *, A, B, C>(
  sa: Lens<S, A>,
  ab: Lens<A, B>,
  bc: Lens<B, C>,
): Lens<S, C> {
  return compose2(compose2(sa, ab), bc);
}
