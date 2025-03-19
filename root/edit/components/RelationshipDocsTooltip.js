/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import HelpIcon from '../../static/scripts/edit/components/HelpIcon.js';
import getRelationshipLinkType
  from '../../static/scripts/edit/utility/getRelationshipLinkType.js';

component RelationshipDocsTooltip(
  relationships: $ReadOnlyArray<RelationshipT>,
) {
  const relationshipTypes = [...new Set(
    relationships.reduce((types: Array<LinkTypeT>, relationship) => {
      const type = getRelationshipLinkType(relationship);
      if (type && type.gid && type.name) {
        types.push(type);
      }
      return types;
    }, []),
  )];

  if (!relationshipTypes?.length) {
    return null;
  }

  const helpContent = (
    <>
      <p>{l('The following relationship types are used in this edit:')}</p>
      <dl>
        {relationshipTypes.map(relationshipType => (
          <React.Fragment key={relationshipType.gid}>
            <dt>
              {expand2react(
                '{doc_link|{name}}',
                {
                  doc_link: {
                    href: '/relationship/' + relationshipType.gid,
                    target: '_blank',
                  },
                  name: relationshipType.name,
                },
              )}
            </dt>
            <dd>
              {expand2react(l_relationships(relationshipType.description))}
            </dd>
          </React.Fragment>
        ))}
      </dl>
    </>
  );

  return (
    <div className="edit-help">
      <HelpIcon
        content={helpContent}
        marginLeft="3px"
      />
    </div>
  );
}

export default RelationshipDocsTooltip;
