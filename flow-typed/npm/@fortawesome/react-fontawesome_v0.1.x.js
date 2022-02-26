// @flow strict

/*
 * Copyright 2018 Fonticons, Inc.
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
 * https://github.com/FortAwesome/react-fontawesome/blob/9f83d49/index.d.ts
 */

declare module '@fortawesome/react-fontawesome' {
  import type {AbstractComponent} from 'react';
  import type {
    Transform,
    IconProp,
    FlipProp,
    SizeProp,
    PullProp,
    RotateProp,
    FaSymbol,
  } from '@fortawesome/fontawesome-svg-core';

  declare export var FontAwesomeIcon: AbstractComponent<FontAwesomeIconProps>;

  declare export interface FontAwesomeIconProps {
    +beat?: boolean,
    +beatFade?: boolean,
    +border?: boolean,
    +bounce?: boolean,
    +className?: string,
    +color?: string,
    +fade?: boolean,
    +fixedWidth?: boolean,
    +flip?: FlipProp,
    +icon: IconProp,
    +inverse?: boolean,
    +listItem?: boolean,
    +mask?: IconProp,
    +maskId?: string,
    +pull?: PullProp,
    +pulse?: boolean,
    +rotation?: RotateProp,
    +shake?: boolean,
    +size?: SizeProp,
    +spin?: boolean,
    +style?: $Partial<CSSStyleDeclaration>,
    +swapOpacity?: boolean,
    +symbol?: FaSymbol,
    +tabIndex?: number,
    +title?: string,
    +titleId?: string,
    +transform?: string | Transform,
  }
}
