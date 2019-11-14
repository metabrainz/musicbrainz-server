// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import React from 'react';

import Autocomplete from '../../common/components/Autocomplete';
import clean from '../../common/utility/clean';
import nonEmpty from '../../common/utility/nonEmpty';

class ArtistCreditNameEditor extends React.Component {
  constructor(props) {
    super(props);

    this.artistName = _.get(props.name, ['artist', 'name'], '');
    this.onArtistChange = this.onArtistChange.bind(this);
    this.onNameBlur = this.onNameBlur.bind(this);
    this.onNameChange = this.onNameChange.bind(this);
    this.onJoinPhraseBlur = this.onJoinPhraseBlur.bind(this);
    this.onJoinPhraseChange = this.onJoinPhraseChange.bind(this);
  }

  onArtistChange(artist) {
    const update = {artist};
    const artistName = artist ? artist.name : '';

    if (!artistName || this.artistName === this.props.name.name) {
      update.name = artistName;
    }

    this.artistName = artistName;
    this.props.onChange(update);
  }

  onNameBlur(event) {
    let newName = clean(event.target.value);

    const artist = this.props.name.artist;
    if (newName === '' && artist) {
      newName = artist.name;
    }

    this.props.onChange({name: newName});
  }

  onNameChange(event) {
    this.props.onChange({name: event.target.value});
  }

  onJoinPhraseBlur(event) {
    if (!this.props.name.automaticJoinPhrase) {
      return;
    }

    /*
     * This is the first value the user has entered into this field. If it is
     * a simple word (such as "and") or an abbreviation (such as "feat.")
     * it is likely that it should be surrounded by spaces. Add those spaces
     * automatically only this first time. Also standardise "feat." according
     * to our guidelines.
     */
    const currentJoinPhrase = event.target.value;

    let joinPhrase = clean(currentJoinPhrase);
    joinPhrase = joinPhrase.replace(/^\s*(feat\.?|ft\.?|featuring)\s*$/i, 'feat.');

    if (/^[A-Za-z]+\.?$/.test(joinPhrase)) {
      joinPhrase = ' ' + joinPhrase + ' ';
    } else if (/^,$/.test(joinPhrase)) {
      joinPhrase = ', ';
    } else if (/^&$/.test(joinPhrase)) {
      joinPhrase = ' & ';
    } else if (/^;$/.test(joinPhrase)) {
      joinPhrase = '; ';
    }

    if (joinPhrase !== currentJoinPhrase) {
      this.props.onChange({joinPhrase});
    }
  }

  onJoinPhraseChange(event) {
    // The join phrase has been changed, it should no longer be automatic.
    this.props.onChange({
      automaticJoinPhrase: false,
      joinPhrase: event.target.value,
    });
  }

  render() {
    const {entity, index, name} = this.props;

    const id = 'ac-' + entity.uniqueID;

    return (
      <tr>
        <td>
          <Autocomplete
            currentSelection={name.artist || {name: name.name}}
            entity="artist"
            inputID={`${id}-artist-${index}`}
            onChange={this.onArtistChange} />
        </td>
        <td>
          <input
            id={`${id}-credited-as-${index}`}
            onBlur={this.onNameBlur}
            onChange={this.onNameChange}
            type="text"
            value={nonEmpty(name.name) ? name.name : ''} />
        </td>
        <td>
          <input
            id={`${id}-join-phrase-${index}`}
            onBlur={this.onJoinPhraseBlur}
            onChange={this.onJoinPhraseChange}
            type="text"
            value={nonEmpty(name.joinPhrase) ? name.joinPhrase : ''} />
        </td>
        <td className="align-right">
          <button className="icon remove-item remove-artist-credit"
                  onClick={this.props.onRemove}
                  title={l('Remove Artist Credit')}
                  type="button" />
        </td>
      </tr>
    );
  }
}

export default ArtistCreditNameEditor;
