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
  +content: React.Node,
  +target: React.Node,
};

const Tooltip = ({
  content,
  target,
}: TooltipProps): React.Element<'div'> => {
  const containerRef = React.useRef<HTMLDivElement | null>(null);

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
    <div className="tooltip-wrapper">
      {target}
      {nonEmpty(content) ? (
        <div className="tooltip-container" ref={containerRef}>
          <div className="tooltip-triangle" />
          <div className="tooltip-content">{content}</div>
        </div>
      ) : null}
    </div>
  );
};

export default Tooltip;
