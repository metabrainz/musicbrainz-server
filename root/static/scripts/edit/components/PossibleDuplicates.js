// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const EntityLink = require('../../common/components/EntityLink');
const i18n = require('../../common/i18n');

class PossibleDuplicates extends React.Component {
  render() {
    return (
      <div>
        <h3>{i18n.l('Possible Duplicates')}</h3>
        <p>{i18n.l('We found the following entities with very similar names:')}</p>
        <ul>
          {this.props.duplicates.map(dupe =>
            <li key={dupe.gid}>
              <EntityLink entity={dupe} target="_blank" />
            </li>
          )}
        </ul>
        <p>
          <label>
            <input type="checkbox" onChange={this.props.checkboxCallback} />
            {' '}
            {i18n.l('Yes, I still want to enter “{entity_name}”.', {entity_name: this.props.name})}
          </label>
        </p>
        <p dangerouslySetInnerHTML={{__html:
          i18n.l('Please enter a {doc_disambiguation|disambiguation} to help distinguish this entity from the others.',
                 {doc_disambiguation: {href: '/doc/Disambiguation_Comment', target: '_blank'}})
          }}></p>
      </div>
    );
  }
}

module.exports = PossibleDuplicates;
