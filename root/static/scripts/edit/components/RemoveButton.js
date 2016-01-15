// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

class RemoveButton extends React.Component {
  render() {
    return (
      <button type="button" className="nobutton remove" onClick={this.props.callback}>
        <div className="remove-item icon img" title={this.props.title}></div>
      </button>
    );
  }
}

module.exports = RemoveButton;
