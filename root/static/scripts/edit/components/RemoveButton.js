// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

class RemoveButton extends React.Component {
  render() {
    return (
      <button
        className="nobutton icon remove-item"
        onClick={this.props.callback}
        title={this.props.title}
        type="button"
      />
    );
  }
}

module.exports = RemoveButton;
