// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const Tooltip = require('./Tooltip');

class HelpIcon extends React.Component {
  constructor(props) {
    super(props);
    this.state = {hover: false};
  }

  render() {
    return (
      <div style={{position: 'relative', display: 'inline-block'}}>
        <div ref="help"
             className="img icon help"
             onMouseEnter={() => this.setState({ hover: true })}
             onMouseLeave={() => this.setState({ hover: false })}>
        </div>
        {this.state.hover &&
          <Tooltip html={this.props.html} hoverCallback={hover => this.setState({ hover })} />}
      </div>
    );
  }
}

module.exports = HelpIcon;
