/*
 * @flow strict
 * MIT License
 *
 * Copyright (c) Sindre Sorhus <sindresorhus@gmail.com>
 * (https://sindresorhus.com)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * This is a fork of https://github.com/sindresorhus/p-throttle that
 *  (1) adds Flow types
 *  (2) makes individual calls abortable
 */

export class ThrottleAbortError extends Error {
  constructor() {
    super('Throttled function aborted');
    this.name = 'AbortError';
  }
}

export type ThrottleOptionsT = {
  +interval: number,
  +limit: number,
};

export type ThrottleResultT<+R: mixed> = {
  +abort: () => void,
  +promise: Promise<R>,
};

const pThrottle = <
  -A: $ReadOnlyArray<mixed>,
  +R: mixed,
>({
  interval,
  limit,
}: ThrottleOptionsT): (
  ((...A) => R | Promise<R>) => ((...A) => ThrottleResultT<R>)
) => {
  const queue: Map<TimeoutID, (mixed) => void> = new Map();

  let currentTick = 0;
  let activeCount = 0;

  const getDelay = () => {
    const now = Date.now();

    if ((now - currentTick) > interval) {
      activeCount = 1;
      currentTick = now;
      return 0;
    }

    if (activeCount < limit) {
      activeCount++;
    } else {
      currentTick += interval;
      activeCount = 1;
    }

    return currentTick - now;
  };

  return (function_) => {
    return (...args) => {
      let timeout;
      let aborted = false;

      return {
        abort: () => {
          clearTimeout(timeout);
          aborted = true;
        },
        promise: new Promise((resolve, reject) => {
          const execute = () => {
            if (aborted) {
              reject(new ThrottleAbortError());
            } else {
              resolve(function_.apply(this, args));
            }
            queue.delete(timeout);
          };

          timeout = setTimeout(execute, getDelay());

          queue.set(timeout, reject);
        }),
      };
    };
  };
};

export default pThrottle;
