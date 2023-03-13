/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import NotFound from '../components/NotFound.js';

type Props = {
  +tag: string,
};

const TagNotFound = ({tag}: Props): React$Element<typeof NotFound> => (
  <NotFound title={l('Tag Not Used')}>
    <p>
      {texp.l(
        'No MusicBrainz entities have yet been tagged with "{tag}".',
        {tag: tag},
      )}
    </p>
    <p>
      {exp.l(
        `If you wish to use this tag, please {url|search} for the entity first
         and apply the tag using the sidebar.`,
        {url: '/search'},
      )}
    </p>
  </NotFound>
);

export default TagNotFound;
