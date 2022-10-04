/*
 * @flow
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import * as React from 'react';

component Bubble(
  children: React.Node,
  controlRef: {+current: HTMLElement | null},
  id: string,
) {
  const bubbleDivRef = React.useRef<HTMLDivElement | null>(null);
  React.useEffect(() => {
    const $bubble = $(bubbleDivRef.current);
    const $parent = $bubble.parent();

    $bubble
      .width($parent.width() - 24)
      .position({
        at: 'right center',
        collision: 'fit none',
        my: 'left top-30',
        of: controlRef.current,
        within: $parent,
      })
      .addClass('left-tail');
  }, [controlRef]);


  return (
    <div
      className="bubble"
      id={id}
      ref={bubbleDivRef}
      // We hide this by a state check so we don't want the CSS display: none
      style={{display: 'block'}}
    >
      {children}
    </div>
  );
}

export default Bubble;
