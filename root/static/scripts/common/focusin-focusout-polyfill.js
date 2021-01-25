/*
 * focusin/out event polyfill (firefox)
 *
 * Copyright (c) 2016 Tobias Buschor (https://twitter.com/tobiasbu)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

const d = document;

if (window.onfocusin === undefined) {
  d.addEventListener('focus', addPolyfill, true);
  d.addEventListener('blur', addPolyfill, true);
  d.addEventListener('focusin', removePolyfill, true);
  d.addEventListener('focusout', removePolyfill, true);
}

function addPolyfill(e) {
  const type = e.type === 'focus' ? 'focusin' : 'focusout';
  const event = new CustomEvent(type, {bubbles: true, cancelable: false});
  event.c1Generated = true;
  e.target.dispatchEvent(event);
}

function removePolyfill(e) {
  if (!e.c1Generated) {
    d.removeEventListener('focus', addPolyfill, true);
    d.removeEventListener('blur', addPolyfill, true);
    d.removeEventListener('focusin', removePolyfill, true);
    d.removeEventListener('focusout', removePolyfill, true);
  }

  setTimeout(function () {
    d.removeEventListener('focusin', removePolyfill, true);
    d.removeEventListener('focusout', removePolyfill, true);
  });
}
