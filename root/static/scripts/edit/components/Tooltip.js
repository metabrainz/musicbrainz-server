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
  +hoverCallback: (boolean) => void,
};

class Tooltip extends React.Component<TooltipProps> {
  containerRef: {current: HTMLDivElement | null};

  constructor(props: TooltipProps) {
    super(props);

    this.containerRef = React.createRef();
  }

  componentDidMount() {
    const container = this.containerRef.current;
    const links = container?.getElementsByTagName('a');
    if (links) {
      for (let i = 0; i < links.length; i++) {
        links[i].setAttribute('target', '_blank');
      }
    }
  }

  render(): React.Element<'div'> {
    const hoverCallback = this.props.hoverCallback;
    return (
      <div
        className="tooltip-container"
        onMouseEnter={() => hoverCallback(true)}
        onMouseLeave={() => hoverCallback(false)}
        ref={this.containerRef}
      >
        <div className="tooltip-triangle" />
        <div className="tooltip-content">{this.props.content}</div>
      </div>
    );
  }
}

export default Tooltip;
