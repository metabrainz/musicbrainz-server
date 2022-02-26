// @flow strict

/*
 * Copyright 2022 Fonticons, Inc.
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
 * Manually converted to Flow syntax from
 * https://github.com/FortAwesome/Font-Awesome/blob/65f4bdb/js-packages/%40fortawesome/fontawesome-svg-core/index.d.ts
 */

declare module '@fortawesome/fontawesome-svg-core' {
  import type {
    IconDefinition,
    IconLookup,
    IconName,
    IconPrefix,
    IconPathData,
    IconPack,
  // eslint-disable-next-line import/no-unresolved
  } from '@fortawesome/fontawesome-common-types';

  declare export var dom: DOM;
  declare export var library: Library;
  declare export var config: Config;
  declare export var parse: {
    icon(parseIconString: string): IconLookup,
    transform(transformString: string): Transform,
  };
  declare export function noAuto(): void;
  declare export function findIconDefinition(
    iconLookup: IconLookup,
  ): IconDefinition;
  declare export function text(content: string, params?: TextParams): Text;
  declare export function counter(
    content: string | number,
    params?: CounterParams,
  ): Counter;
  declare export function toHtml(content: any): string;
  declare export function toHtml(abstractNodes: AbstractElement): string;
  declare export function layer(
    assembler: (
      addLayerCallback: (
        layerToAdd: IconOrText | $ReadOnlyArray<IconOrText>,
      ) => void
    ) => void,
    params?: LayerParams
  ): Layer;
  declare export function icon(
    icon: IconName | IconLookup,
    params?: IconParams,
  ): Icon;
  declare export type IconProp =
    | IconName
    | [IconPrefix, IconName]
    | IconLookup;
  declare export type FlipProp = 'horizontal' | 'vertical' | 'both';
  declare export type SizeProp =
    | 'xs'
    | 'lg'
    | 'sm'
    | '1x'
    | '2x'
    | '3x'
    | '4x'
    | '5x'
    | '6x'
    | '7x'
    | '8x'
    | '9x'
    | '10x';
  declare export type PullProp = 'left' | 'right';
  declare export type RotateProp = 90 | 180 | 270;
  declare export type FaSymbol = string | boolean;
  declare export interface Config {
    +autoA11y: boolean,
    +autoAddCss: boolean,
    +autoReplaceSvg: boolean | 'nest',
    +familyPrefix: IconPrefix,
    +keepOriginalSource: boolean,
    +measurePerformance: boolean,
    +observeMutations: boolean,
    +replacementClass: string,
    +searchPseudoElements: boolean,
    +showMissingIcons: boolean,
  }
  declare export interface AbstractElement {
    +attributes: any,
    +children?: $ReadOnlyArray<AbstractElement>,
    +tag: string,
  }
  declare export interface FontawesomeObject {
    +abstract: $ReadOnlyArray<AbstractElement>,
    +html: $ReadOnlyArray<string>,
    +node: HTMLCollection<HTMLElement>,
  }
  declare export interface Icon extends FontawesomeObject, IconDefinition {
    +type: 'icon',
  }
  declare export interface Text extends FontawesomeObject {
    +type: 'text',
  }
  declare export interface Counter extends FontawesomeObject {
    +type: 'counter',
  }
  declare export interface Layer extends FontawesomeObject {
    +type: 'layer',
  }
  declare type IconOrText = Icon | Text;
  declare export interface Attributes {
    +[key: string]: number | string,
  }
  declare export interface Styles {
    +[key: string]: string,
  }
  declare export interface Transform {
    +flipX?: boolean,
    +flipY?: boolean,
    +rotate?: number,
    +size?: number,
    +x?: number,
    +y?: number,
  }
  declare export interface Params {
    +attributes?: Attributes,
    +classes?: string | $ReadOnlyArray<string>,
    +styles?: Styles,
    +title?: string,
    +titleId?: string,
  }
  declare export interface CounterParams extends Params {
  }
  declare export interface LayerParams {
    +classes?: string | $ReadOnlyArray<string>,
  }
  declare export interface TextParams extends Params {
    +transform?: Transform,
  }
  declare export interface IconParams extends Params {
    +mask?: IconLookup,
    +maskId?: string,
    +symbol?: FaSymbol,
    +transform?: Transform,
  }
  declare export interface DOM {
    css(): string,
    i2svg(params?: {+callback?: () => void, +node: Node}): Promise<void>,
    insertCss(): string,
    watch(): void,
  }
  declare type IconDefinitionOrPack = IconDefinition | IconPack;
  declare export interface Library {
    add(...definitions: $ReadOnlyArray<IconDefinitionOrPack>): void,
    reset(): void,
  }
}
