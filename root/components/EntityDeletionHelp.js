/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';

type Props = {
  +children?: React$Node,
  +entity: CoreEntityT,
};

const EntityDeletionHelp = ({
  children,
  entity,
}: Props): React$Element<'div'> => (
  <div id="removal-help">
    <p>
      {exp.l(
        'Are you sure you wish to remove {entity} from MusicBrainz?',
        {entity: <EntityLink entity={entity} />},
      )}
    </p>
    <p>
      {exp.l(
        `If it’s a duplicate,
        {doc_merge|you should probably merge it instead}.
        If it just has some small errors, it’s usually better
        to just fix those.`,
        {doc_merge: '/doc/Merge_Rather_Than_Delete'},
      )}
    </p>
    {children}
  </div>
);

export default EntityDeletionHelp;
