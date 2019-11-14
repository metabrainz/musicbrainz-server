// @flow
// Copyright (C) 2014 Khan Academy
// Copyright (C) 2015 MetaBrainz Foundation

// The source code contained in this file was originally derived from
// https://raw.githubusercontent.com/Khan/react-components/9984740/js/info-tip.jsx
// which is released under the MIT license. The full terms of this license can
// be found in the original source code repository at
// https://raw.githubusercontent.com/Khan/react-components/9984740/LICENSE

import * as React from 'react';
import ReactDOM from 'react-dom';

type TooltipProps = {
  +hoverCallback: (boolean) => void,
  +content: React.Node,
};

class Tooltip extends React.Component<TooltipProps> {
  componentDidMount() {
    const element: any = ReactDOM.findDOMNode(this);
    const links = element.getElementsByTagName('a');
    for (let i = 0; i < links.length; i++) {
      links[i].setAttribute('target', '_blank');
    }
  }

  render() {
    var hoverCallback = this.props.hoverCallback;
    return (
      <div
        className="tooltip-container"
        onMouseEnter={() => hoverCallback(true)}
        onMouseLeave={() => hoverCallback(false)}
      >
        <div className="tooltip-triangle" />
        <div className="tooltip-content">{this.props.content}</div>
      </div>
    );
  }
}

export default Tooltip;
