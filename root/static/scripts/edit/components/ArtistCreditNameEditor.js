// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const Autocomplete = require('../../common/components/Autocomplete');
const {l} = require('../../common/i18n');
const clean = require('../../common/utility/clean');
const nonEmpty = require('../../common/utility/nonEmpty');

class ArtistCreditNameEditor extends React.Component {
  constructor(props) {
    super(props);
    this.onArtistChange = this.onArtistChange.bind(this);
    this.onNameChange = this.onNameChange.bind(this);
    this.onJoinPhraseBlur = this.onJoinPhraseBlur.bind(this);
    this.onJoinPhraseChange = this.onJoinPhraseChange.bind(this);
  }

  onArtistChange(artist) {
    const update = {artist};
    const artistName = artist ? artist.name : '';
    const currentArtistName = _.get(this.props.name, ['artist', 'name'], '');

    if (!artistName || currentArtistName === this.props.name.name) {
      update.name = artistName;
    }

    this.props.onChange(update);
  }

  onNameChange(event) {
    let newName = event.target.value;
    const artist = this.artist;

    if (newName === '' && artist) {
      newName = artist.name;
    }

    this.props.onChange({name: newName});
  }

  onJoinPhraseBlur(event) {
    if (!this.props.name.automaticJoinPhrase) {
      return;
    }

    // This is the first value the user has entered into this field. If it is a
    // simple word (such as "and") or an abbreviation (such as "feat.") it is
    // likely that it should be surrounded by spaces. Add those spaces
    // automatically only this first time. Also standardise "feat." according
    // to our guidelines.
    let joinPhrase = clean(event.target.value);
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

    // The join phrase has been changed, it should no langer be automatic.
    this.props.onChange({joinPhrase: joinPhrase, automaticJoinPhrase: false});
  }

  onJoinPhraseChange(event) {
    this.props.onChange({joinPhrase: event.target.value});
  }

  render() {
    const name = this.props.name;

    return (
      <tr>
        <td>
          <Autocomplete
            currentSelection={name.artist || {name: name.name}}
            entity="artist"
            onChange={this.onArtistChange} />
        </td>
        <td>
          <input
            onChange={this.onNameChange}
            type="text"
            value={nonEmpty(name.name) ? name.name : ''} />
        </td>
        <td>
          <input
            onBlur={this.onJoinPhraseBlur}
            onChange={this.onJoinPhraseChange}
            type="text"
            value={nonEmpty(name.joinPhrase) ? name.joinPhrase : ''} />
        </td>
        <td style={{textAlign: 'right'}}>
          <button className="icon remove-item remove-artist-credit"
                  onClick={this.props.onRemove}
                  title={l('Remove Artist Credit')}
                  type="button" />
        </td>
      </tr>
    );
  }
}

module.exports = ArtistCreditNameEditor;
