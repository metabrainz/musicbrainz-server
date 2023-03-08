/*
 * @flow strict
 * Copyright (C) 2014 Khan Academy
 * Copyright (C) 2015 MetaBrainz Foundation
 */

/*
 * The source code contained in this file was originally derived from
 * https://raw.githubusercontent.com/Khan/react-components/9984740/js/info-tip.jsx
 * which is released under the MIT license. The full terms of this license can
 * be found in the original source code repository at
 * https://raw.githubusercontent.com/Khan/react-components/9984740/LICENSE
 */

import * as React from 'react';

type TooltipProps = {
  +content: React$Node,
  +target: React$Node,
};

const Tooltip = ({
  content,
  target,
}: TooltipProps): React$Element<'span'> => {
  const containerRef = React.useRef<HTMLSpanElement | null>(null);

  React.useEffect(() => {
    const container = containerRef.current;
    const links = container?.getElementsByTagName('a');
    if (links) {
      for (let i = 0; i < links.length; i++) {
        links[i].setAttribute('target', '_blank');
      }
    }
  }, []);

  return (
    <span className="tooltip-wrapper">
      {target}
      {nonEmpty(content) ? (
        <span className="tooltip-container" ref={containerRef}>
          <span className="tooltip-triangle" />
          <span className="tooltip-content">{content}</span>
        </span>
      ) : null}
    </span>
  );
};

export default Tooltip;
