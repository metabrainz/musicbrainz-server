/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * React doesn't allow setting an input's `value` directly: it overrides the
 * value setter, so we must call the original explicitly. We then trigger an
 * input event to simulate typing.
 *
 * This function generally shouldn't be used outside of tests unless there's
 * no good alternative.
 */
export default function setInputValueForReact(
  input: HTMLInputElement,
  value: string,
): void {
  const setInputValue = Object.getOwnPropertyDescriptor(
    input.constructor.prototype,
    'value',
  )?.set;
  if (setInputValue != null) {
    setInputValue.call(input, value);
    input.dispatchEvent(new Event('input', {bubbles: true}));
  }
}
