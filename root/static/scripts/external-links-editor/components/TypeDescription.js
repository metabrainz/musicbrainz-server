/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../../common/i18n/expand2react.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import HelpIcon from '../../edit/components/HelpIcon.js';

component TypeDescription(
  type: number | null
) renders HelpIcon {
  const linkType = type ? linkedEntities.link_type[type] : null;
  let typeDescription: Expand2ReactOutput = '';

  if (linkType && linkType.description) {
    typeDescription = exp.l('{description} ({url|more documentation})', {
      description: expand2react(l_relationships(linkType.description)),
      url: '/relationship/' + linkType.gid,
    });
  }

  return (
    <HelpIcon
      content={
        <div style={{textAlign: 'left'}}>{typeDescription}</div>
      }
    />
  );
}

export default TypeDescription;
