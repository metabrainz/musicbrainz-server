/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare module 'tabbable' {
  declare type CommonOptions = {
    +displayCheck?:
      | 'full'
      | 'legacy-full'
      | 'non-zero-area'
      | 'none',
    +getShadowRoot?:
      | boolean
      | ((HTMLElement) => ShadowRoot | boolean | void),
    };

  declare type FocusableOptions = {
    +includeContainer?: boolean,
  };

  declare export function focusable(
    container: Node,
    options?: $ReadOnly<{
      ...CommonOptions,
      ...FocusableOptions,
    }>,
  ): Array<HTMLElement>;

  declare export function tabbable(
    container: Node,
    options?: $ReadOnly<{
      ...CommonOptions,
      ...FocusableOptions,
    }>,
  ): Array<HTMLElement>;

  declare export function isTabbable(
    node: Node,
    options?: CommonOptions,
  ): boolean;

  declare export function isFocusable(
    node: Node,
    options?: CommonOptions,
  ): boolean;

  declare export function getTabIndex(
    node: HTMLElement,
  ): number;
}
