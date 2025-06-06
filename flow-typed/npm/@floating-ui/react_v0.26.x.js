/*
 * @flow strict
 *
 * MIT License
 *
 * Copyright (C) 2021 Floating UI contributors
 * Copyright (C) 2024 MetaBrainz Foundation
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
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

declare module '@floating-ui/react' {
  /*
   * Note: These types are incomplete, and mainly express the parts of the
   * API we actually use.
   */

  // https://github.com/floating-ui/floating-ui/blob/672e458/packages/utils/src/index.ts
  declare export type Alignment = 'start' | 'end';
  declare export type AlignedPlacement =
    | 'top-start' | 'top-end'
    | 'right-start' | 'right-end'
    | 'bottom-start' | 'bottom-end'
    | 'left-start' | 'left-end';
  declare export type Axis = 'x' | 'y';
  declare export type Length = 'width' | 'height';
  declare export type Placement = Side | AlignedPlacement;
  declare export type Side = 'top' | 'right' | 'bottom' | 'left';
  declare export type Strategy = 'absolute' | 'fixed';

  // eslint-disable-next-line no-unused-vars
  declare export type Coords = {+[key in Axis]: number};
  // eslint-disable-next-line no-unused-vars
  declare export type Dimensions = {+[key in Length]: number};
  // eslint-disable-next-line no-unused-vars
  declare export type SideObject = {+[key in Side]: number};

  declare export type ClientRectObject = Rect & SideObject;
  declare export type Padding = number | Partial<SideObject>;
  declare export type Rect = Coords & Dimensions;

  // https://floating-ui.com/docs/detectoverflow#boundary
  declare export type Boundary =
    | 'clippingAncestors'
    | Element
    | $ReadOnlyArray<Element>
    | Rect;
  declare export type ElementContext = 'reference' | 'floating';
  declare export type RootBoundary = 'viewport' | 'document' | Rect;

  declare export interface VirtualElement {
    +contextElement?: Element,
    getBoundingClientRect(): ClientRectObject,
  }

  declare export type ReferenceElement = Element | VirtualElement;
  declare export type FloatingElement = HTMLElement;

  declare export interface Elements {
    +floating: FloatingElement,
    +reference: ReferenceElement,
  }

  declare export type MiddlewareState = $ReadOnly<{
    ...Coords,
    +elements: Elements,
    +initialPlacement: Placement,
    +placement: Placement,
    +strategy: Strategy,
    ...
  }>;

  declare export type Derivable<T> = (state: MiddlewareState) => T;

  declare export type MiddlewareReturn = $ReadOnly<{
    ...Partial<Coords>,
    +data?: {+[key: string]: mixed},
  }>;

  declare export interface Middleware {
    +fn: (state: MiddlewareState) =>
      | Promise<MiddlewareReturn>
      | MiddlewareReturn,
    +name: string,
    +options?: mixed,
  }

  declare export type DetectOverflowOptions = Partial<{
    +altBoundary: boolean,
    +boundary: Boundary,
    +elementContext: ElementContext,
    +padding: Padding,
    +rootBoundary: RootBoundary,
  }>;

  declare export type ElementProps = {...};

  declare export type FloatingContext = {...};

  /*
   * arrow()
   */
  declare export type ArrowOptions = {
    +element:
      | Element
      | null
      | {current: Element | null},
    +padding?: Padding,
  };

  declare export function arrow(
    options?: ArrowOptions,
  ): Middleware;

  /*
   * autoPlacement()
   */
  declare export function autoPlacement(): Middleware;

  /*
   * autoUpdate()
   */
  export type AutoUpdateOptions = Partial<{
    +ancestorResize: boolean,
    +ancestorScroll: boolean,
    +animationFrame: boolean,
    +elementResize: boolean,
    +layoutShift: boolean,
  }>;

  declare export function autoUpdate(
    reference: ReferenceElement,
    floating: HTMLElement,
    update: () => void,
    options?: AutoUpdateOptions,
  ): (() => void);

  /*
   * offset()
   */
  declare export type OffsetOptions =
    | number
    | {
        +alignmentAxis?: number | null,
        +crossAxis?: number,
        +mainAxis?: number,
      };

  declare export function offset(OffsetOptions): Middleware;

  /*
   * shift()
   */
  declare export function shift(): Middleware;

  /*
   * size()
   */
  declare export type SizeOptions = $ReadOnly<{
    ...DetectOverflowOptions,
    apply?: (
      state: $ReadOnly<{
        ...MiddlewareState,
        availableHeight: number,
        availableWidth: number,
        ...
      }>,
    ) => void,
  }>;

  declare export function size(SizeOptions): Middleware;

  /*
   * useClick()
   */
  declare export function useClick(
    context: FloatingContext,
  ): ElementProps;

  /*
   * useDismiss()
   */
  declare export interface UseDismissProps {
    outsidePress?: boolean | ((event: MouseEvent) => boolean),
    outsidePressEvent?: 'pointerdown' | 'mousedown' | 'click',
  }

  declare export function useDismiss(
    context: FloatingContext,
    props: UseDismissProps,
  ): ElementProps;

  /*
   * useFloating()
   */
  declare export interface UseFloatingOptions {
    middleware?: $ReadOnlyArray<?Middleware | false>,
    nodeId?: string,
    onOpenChange?: (
      open: boolean,
      event: Event,
      reason: string,
    ) => void,
    open?: boolean,
    strategy?: 'fixed' | 'absolute',
    whileElementsMounted?: (
      reference: ReferenceElement,
      floating: HTMLElement,
      update: () => void,
    ) => (() => void),
  }

  declare export interface UseFloatingReturn {
    context: FloatingContext,
    floatingStyles: {...},
    refs: {
      +floating: {current: HTMLElement | null},
      +reference: {current: ReferenceElement | null},
      +setFloating: (node: HTMLElement | null) => void,
      +setReference: (node: ReferenceElement | null) => void,
    },
  }

  declare export function useFloating(
    options?: UseFloatingOptions,
  ): UseFloatingReturn;

  /*
   * useFloatingNodeId()
   */
  declare export function useFloatingNodeId(customParentId?: string): string;

  /*
   * useFloatingParentNodeId()
   */
  declare export function useFloatingParentNodeId(): string | null;

  /*
   * useInteractions()
   */
  declare export type UseInteractionsReturn = {
    +getFloatingProps: (
      userProps?: ReactDOM$HTMLElementProps,
    ) => ReactDOM$HTMLElementProps,
    +getReferenceProps: (
      userProps?: ReactDOM$HTMLElementProps,
    ) => ReactDOM$HTMLElementProps,
    ...
  };

  declare export function useInteractions(
    propsList: $ReadOnlyArray<ElementProps | void>,
  ): UseInteractionsReturn;

  /*
   * useMergeRefs()
   */
  declare export function useMergeRefs<Instance>(
    refs: $ReadOnlyArray<{-current: Instance} | void>,
  ): ((Instance | null) => mixed);

  /*
   * FloatingArrow
   */
  declare export type FloatingArrowProps = {
    +context: FloatingContext,
    +d?: string,
    +fill?: string,
    +height?: number,
    +staticOffset?: string | number | null,
    +stroke?: string,
    +strokeWidth?: number,
    +tipRadius?: number,
    +width?: number,
  };

  declare export const FloatingArrow:
    component(ref: React.RefSetter<Element>, ...FloatingArrowProps);

  /*
   * FloatingFocusManager
   */
  declare export type FloatingFocusManagerProps = {
    +children: React.Node,
    +closeOnFocusOut?: boolean,
    +context: FloatingContext,
    +initialFocus?: number | {current: HTMLElement | null},
    +modal?: boolean,
    +returnFocus?: boolean,
  };

  declare export const FloatingFocusManager:
    component(...FloatingFocusManagerProps);

  /*
   * FloatingNode
   */
  declare export type FloatingNodeProps = {
    +children: React.Node,
    +id?: string,
  };

  declare export const FloatingNode:
    component(...FloatingNodeProps);

  /*
   * FloatingOverlay
   */
  declare export type FloatingOverlayProps = {
    +children: React.Node,
    +className?: string,
    +lockScroll?: boolean,
    +onClick?: (SyntheticMouseEvent<HTMLDivElement>) => mixed,
  };

  declare export const FloatingOverlay:
    component(...FloatingOverlayProps);

  /*
   * FloatingPortal
   */
  declare export type FloatingPortalProps = {
    +children: React.Node,
    +id?: string,
  };

  declare export const FloatingPortal:
    component(...FloatingPortalProps);

  /*
   * FloatingTree
   */
  declare export type FloatingTreeProps = {
    +children: React.Node,
  };

  declare export const FloatingTree:
    component(...FloatingTreeProps);
}
