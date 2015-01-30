// Copyright (c) 2014 Khan Academy
// The source code contained in this file was originally derived from
// https://raw.githubusercontent.com/Khan/react-components/9984740/js/info-tip.jsx
// which is released under the MIT license. The full terms of this license can
// be found in the original source code repository at
// https://raw.githubusercontent.com/Khan/react-components/9984740/LICENSE

var React = require('react');
var RCSS = require('rcss');
var _ = require('underscore');

var colors = {
    grayLight: '#aaa',
    basicBorderColor: '#ccc',
    white: '#fff'
};

var infoTip = {
    display: 'inline-block',
    marginLeft: '5px',
    position: 'relative'
};

var infoTipI = {
    cursor: 'pointer'
};

var infoTipContainer = {
    position: 'absolute',
    'top': '-12px',
    left: '22px',
    zIndex: '1000'
};

var triangleBeforeAfter = {
    borderBottom: '9px solid transparent',
    borderTop: '9px solid transparent',
    content: ' ',
    height: '0',
    position: 'absolute',
    'top': '0',
    width: '0'
};

var infoTipTriangle = {
    height: '10px',
    left: '0',
    position: 'absolute',
    'top': '8px',
    width: '0',
    zIndex: '1',

    ':before': _.extend({}, triangleBeforeAfter, {
        borderRight: '9px solid #bbb',
        right: '0',
    }),

    ':after': _.extend({}, triangleBeforeAfter, {
        borderRight: `9px solid ${colors.white}`,
        right: '-1px'
    })
};

var basicBorder = {
    border: `1px solid ${colors.basicBorderColor}`
};

var boxShadow = str => { return { boxShadow: str }; };

var verticalShadow = RCSS.merge(
    basicBorder,
    boxShadow(`0 1px 3px ${colors.basicBorderColor}`),
    { borderBottom: `1px solid ${colors.grayLight}` }
);

var infoTipContentContainer = RCSS.merge(verticalShadow, {
    background: colors.white,
    padding: '5px 10px',
    width: '240px'
});

RCSS.createClass(infoTip);
RCSS.createClass(infoTipI);
RCSS.createClass(infoTipTriangle);
RCSS.createClass(verticalShadow);
RCSS.createClass(infoTipContainer);
RCSS.createClass(infoTipContentContainer);

var questionMark = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3NpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1NDkxMSwgMjAxMy8xMC8yOS0xMTo0NzoxNiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2N2M3NTAxYS04YmVlLTQ0M2MtYmRiNS04OGM2N2IxN2NhYzEiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OUJCRTk4Qjc4NjAwMTFFMzg3QUJDNEI4Mzk2QTRGQkQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OUJCRTk4QjY4NjAwMTFFMzg3QUJDNEI4Mzk2QTRGQkQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NGE5ZDI0OTMtODk1NC00OGFkLTlhMTgtZDAwM2MwYWNjNDJlIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjY3Yzc1MDFhLThiZWUtNDQzYy1iZGI1LTg4YzY3YjE3Y2FjMSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pqm89uYAAADMSURBVHjaXJA9DoJAEIUH1M4TUHIFsCMGen9OwCGw1YRGW2ntKel0exsojHIBC0ouQAyUviFDstmXfNmZeS+zm7XSNCXRFiRgJf0bXIHixpbhGdxBBJYC1w/xaA424MhNEATkui71fU9KqfEU78UbD9PdbJRlOdae55GmhIP+1NV1TcMwkOM41DSNHvRtMhTHMRVFQW3b6mOLgx99kue5GRp/gIOZuZGvNpTNwjD8oliANU+qqqKu6/TQBdymN57AHjzBT+B6Jx79BRgAvc49kQA4yxgAAAAASUVORK5CYII='; // @NoLint

var InfoTip = React.createClass({
    getInitialState: function() {
        return {
            hover: false
        };
    },

    render: function() {
        return <div className={infoTip.className}>
            <img width={10}
                 height={10}
                 src={questionMark}
                 onMouseEnter={this.handleMouseEnter}
                 onMouseLeave={this.handleMouseLeave} />
            <div className={infoTipContainer.className}
                 style={{display: this.state.hover ? 'block' : 'none'}}>
                <div className={infoTipTriangle.className} />
                {/* keep the classes here - used for selectors on KA */}
                <div className={infoTipContentContainer.className}>
                    {this.props.children}
                </div>
            </div>
        </div>;
    },

    handleMouseEnter: function() {
        this.setState({hover: true});
    },

    handleMouseLeave: function() {
        this.setState({hover: false});
    }
});

module.exports = InfoTip;
