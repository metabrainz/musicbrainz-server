/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../../common/components/EntityLink.js';

type PropsT = {
  duplicates: $ReadOnlyArray<CoreEntityT>,
  name: string,
  onCheckboxChange: (event: SyntheticEvent<HTMLInputElement>) => void,
};

const PossibleDuplicates = ({
  duplicates,
  name,
  onCheckboxChange,
}: PropsT): React$Element<'div'> => (
  <div>
    <h3>{l('Possible Duplicates')}</h3>
    <p>{l('We found the following entities with very similar names:')}</p>
    <ul>
      {duplicates.map(dupe => (
        <li key={dupe.gid}>
          <EntityLink entity={dupe} target="_blank" />
        </li>
      ))}
    </ul>
    <p>
      <label>
        <input onChange={onCheckboxChange} type="checkbox" />
        {' '}
        {texp.l(
          'Yes, I still want to enter “{entity_name}”.',
          {entity_name: name},
        )}
      </label>
    </p>
    <p>
      {exp.l(
        `Please enter a {doc_disambiguation|disambiguation}
          to help distinguish this entity from the others.`,
        {
          doc_disambiguation: {
            href: '/doc/Disambiguation_Comment',
            target: '_blank',
          },
        },
      )}
    </p>
  </div>
);

export default PossibleDuplicates;
