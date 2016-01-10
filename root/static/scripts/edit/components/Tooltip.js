// Copyright (C) 2014 Khan Academy
// Copyright (C) 2015 MetaBrainz Foundation

// The source code contained in this file was originally derived from
// https://raw.githubusercontent.com/Khan/react-components/9984740/js/info-tip.jsx
// which is released under the MIT license. The full terms of this license can
// be found in the original source code repository at
// https://raw.githubusercontent.com/Khan/react-components/9984740/LICENSE

const React = require('react');
const ReactDOM = require('react-dom');
const RCSS = require('rcss');
const PropTypes = React.PropTypes;

var colors = {
  grayLight: '#aaa',
  basicBorderColor: '#ccc',
  white: '#fff'
};

var infoTipContainer = RCSS.registerClass({
  position: 'absolute',
  top: '-12px',
  left: '22px',
  zIndex: '1000'
});

var triangleBeforeAfter = {
  borderBottom: '9px solid transparent',
  borderTop: '9px solid transparent',
  content: ' ',
  height: '0',
  position: 'absolute',
  top: '0',
  width: '0'
};

var infoTipTriangle = RCSS.registerClass({
  height: '10px',
  left: '0',
  position: 'absolute',
  top: '8px',
  width: '0',
  zIndex: '1',

  ':before': RCSS.cascade(triangleBeforeAfter, {
    borderRight: '9px solid #bbb',
    right: '0',
  }),

  ':after': RCSS.cascade(triangleBeforeAfter, {
    borderRight: `9px solid ${colors.white}`,
    right: '-1px'
  })
});

var basicBorder = {
  border: `1px solid ${colors.basicBorderColor}`
};

var verticalShadow = RCSS.cascade(
  basicBorder,
  { boxShadow: `0 1px 3px ${colors.basicBorderColor}` },
  { borderBottom: `1px solid ${colors.grayLight}` }
);

var infoTipContentContainer = RCSS.registerClass(
  RCSS.cascade(verticalShadow, {
    background: colors.white,
    padding: '5px 10px',
    width: '240px'
  })
);

RCSS.injectAll();

class Tooltip extends React.Component {
  componentDidMount() {
    $(ReactDOM.findDOMNode(this)).find('a').attr('target', '_blank');
  }

  render() {
    var hoverCallback = this.props.hoverCallback;
    return (
      <div className={infoTipContainer.className}
           onMouseEnter={() => hoverCallback(true)}
           onMouseLeave={() => hoverCallback(false)}>
        <div className={infoTipTriangle.className} />
        <div className={infoTipContentContainer.className} dangerouslySetInnerHTML={{__html: this.props.html}} />
      </div>
    );
  }
}

Tooltip.propTypes = {hoverCallback: PropTypes.func.isRequired};

module.exports = Tooltip;
