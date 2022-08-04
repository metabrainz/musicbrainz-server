/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {bracketedText} from '../utility/bracketed';
import {kebabCase} from '../utility/strings';
import {SidebarProperty}
  from '../../../../layout/components/sidebar/SidebarProperties';

import CollapsibleList from './CollapsibleList';

const buildAttributeListRow = (attribute: WorkAttributeT) => (
  <li
    className={'work-attribute work-attribute-' +
      kebabCase(attribute.typeName)}
    key={attribute.id}
  >
    {attribute.value_id == null
      ? attribute.value
      : lp_attributes(
        attribute.value, 'work_attribute_type_allowed_value',
      )}
    {' '}
    {bracketedText(lp_attributes(
      attribute.typeName,
      'work_attribute_type',
    ))}
  </li>
);

const buildAttributeSidebarRow = (attribute: WorkAttributeT) => (
  <SidebarProperty
    className={'work-attribute work-attribute-' +
      kebabCase(attribute.typeName)}
    key={attribute.id}
    label={addColonText(
      lp_attributes(attribute.typeName, 'work_attribute_type'),
    )}
  >
    {attribute.value_id == null
      ? attribute.value
      : lp_attributes(
        attribute.value, 'work_attribute_type_allowed_value',
      )}
  </SidebarProperty>
);

type AttributeListProps = {|
  +attributes: ?$ReadOnlyArray<WorkAttributeT>,
  +isSidebar?: boolean,
|};

const AttributeList = ({
  attributes,
  isSidebar = false,
}: AttributeListProps) => (
  <CollapsibleList
    ContainerElement={isSidebar ? 'dl' : 'ul'}
    InnerElement={isSidebar ? 'p' : 'li'}
    ariaLabel={l('Work Attributes')}
    buildRow={isSidebar ? buildAttributeSidebarRow : buildAttributeListRow}
    className={isSidebar ? 'properties work-attributes' : 'work-attributes'}
    rows={attributes}
    showAllTitle={l('Show all attributes')}
    showLessTitle={l('Show less attributes')}
    toShowAfter={1}
    toShowBefore={2}
  />
);

export default (hydrate<AttributeListProps>(
  'div.entity-attributes-container',
  AttributeList,
): React.AbstractComponent<AttributeListProps, void>);
