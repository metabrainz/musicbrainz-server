/*
 * @flow strict-local
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import openEditsForRelIconUrl
  from '../../../images/icons/open_edits_for_rel.svg';
import type {
  RelationshipStateT,
} from '../../relationship-editor/types.js';
import getOpenEditsLink
  from '../../relationship-editor/utility/getOpenEditsLink.js';
import type {
  LinkRelationshipT,
} from '../externalLinks.js';

import Tooltip from './Tooltip.js';

type PropsT = {
  +relationship: LinkRelationshipT | RelationshipStateT,
};

const RelationshipPendingEditsWarning = ({
  relationship,
}: PropsT): React$Element<React$FragmentType> | null => {
  const hasPendingEdits = relationship.editsPending;
  const openEditsLink = getOpenEditsLink(relationship);

  return hasPendingEdits && nonEmpty(openEditsLink) ? (
    <>
      {' '}
      <Tooltip
        content={exp.l(
          'This relationship has {edit_search|open edits}.',
          {edit_search: openEditsLink},
        )}
        target={
          <img
            alt={l('This relationship has open edits.')}
            className="info"
            height={16}
            src={openEditsForRelIconUrl}
            style={{verticalAlign: 'middle'}}
          />
        }
      />
    </>
  ) : null;
};

export default RelationshipPendingEditsWarning;
