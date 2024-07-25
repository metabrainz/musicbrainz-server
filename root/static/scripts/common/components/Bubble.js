/*
 * @flow
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  type UseFloatingReturn,
  arrow,
  autoUpdate,
  FloatingArrow,
  offset,
  size,
  useFloating,
} from '@floating-ui/react';
import * as React from 'react';

component Bubble(
  children: React.Node,
  controlRef: {+current: HTMLElement | null},
  id: string,
) {
  const arrowRef = React.useRef<Element | null>(null);

  const {refs, floatingStyles, context}: UseFloatingReturn = useFloating({
    middleware: [
      arrow({element: arrowRef}),
      offset(16),
      size({
        apply({availableWidth}) {
          const floatingElement = refs.floating.current;
          if (floatingElement) {
            floatingElement.style.width =
              String(availableWidth - 16) + 'px';
          }
        },
      }),
    ],
    open: true,
    placement: 'right',
    whileElementsMounted: (referenceEl, floatingEl, update) => {
      return autoUpdate(referenceEl, floatingEl, update, {
        ancestorResize: true,
        ancestorScroll: false,
        animationFrame: false,
        elementResize: true,
        layoutShift: true,
      });
    },
  });

  React.useEffect(() => {
    refs.setReference(controlRef.current);
  }, [controlRef]);

  return (
    <div
      className="bubble"
      id={id}
      ref={refs.setFloating}
      style={{
        ...floatingStyles,
        /*
         * We hide this by a state check so we don't want the CSS
         * display: none.
         */
        display: 'block',
      }}
    >
      {children}
      <FloatingArrow
        context={context}
        fill="currentColor"
        height={12}
        ref={arrowRef}
        width={24}
      />
    </div>
  );
}

export default Bubble;
