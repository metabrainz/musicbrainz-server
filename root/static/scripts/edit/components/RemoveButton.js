/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

class RemoveButton extends React.Component {
  render() {
    return (
      <button
        className="nobutton icon remove-item"
        onClick={this.props.onClick}
        title={this.props.title}
        type="button"
      />
    );
  }
}

export default RemoveButton;
