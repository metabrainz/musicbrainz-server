// Copyright (C) 2014 Khan Academy
// Copyright (C) 2015 MetaBrainz Foundation

// The source code contained in this file was originally derived from
// https://raw.githubusercontent.com/Khan/react-components/9984740/js/info-tip.jsx
// which is released under the MIT license. The full terms of this license can
// be found in the original source code repository at
// https://raw.githubusercontent.com/Khan/react-components/9984740/LICENSE

const React = require('react');
const ReactDOM = require('react-dom');
const PropTypes = React.PropTypes;

class Tooltip extends React.Component {
  componentDidMount() {
    $(ReactDOM.findDOMNode(this)).find('a').attr('target', '_blank');
  }

  render() {
    var hoverCallback = this.props.hoverCallback;
    return (
      <div className="tooltip-container"
           onMouseEnter={() => hoverCallback(true)}
           onMouseLeave={() => hoverCallback(false)}>
        <div className="tooltip-triangle" />
        <div className="tooltip-content" dangerouslySetInnerHTML={{__html: this.props.html}} />
      </div>
    );
  }
}

Tooltip.propTypes = {hoverCallback: PropTypes.func.isRequired};

module.exports = Tooltip;
