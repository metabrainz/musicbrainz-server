/*
 * @flow strict-local
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import openEditsForEntityIconUrl
  from '../../../images/icons/open_edits_for_entity.svg';
import entityHref from '../../common/utility/entityHref.js';

import Tooltip from './Tooltip.js';

type PropsT = {
  +entity: RelatableEntityT,
};

const EntityPendingEditsWarning = ({
  entity,
}: PropsT): React.MixedElement | null => {
  const hasPendingEdits = Boolean(entity.editsPending);
  const openEditsLink = entityHref(entity, '/open_edits');

  return hasPendingEdits && nonEmpty(openEditsLink) ? (
    <>
      {' '}
      <Tooltip
        content={exp.l(
          'This entity has {edits_link|open edits}.',
          {edits_link: openEditsLink},
        )}
        target={
          <img
            alt={l('This entity has open edits.')}
            className="info"
            height={16}
            src={openEditsForEntityIconUrl}
            style={{verticalAlign: 'middle'}}
          />
        }
      />
    </>
  ) : null;
};

export default EntityPendingEditsWarning;
