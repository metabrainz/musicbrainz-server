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

const TO_SHOW_BEFORE = 2;
const TO_SHOW_AFTER = 1;
const TO_TRIGGER_COLLAPSE = TO_SHOW_BEFORE + TO_SHOW_AFTER + 2;

const buildAttributeListRow = (attribute) => (
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

const buildAttributeSidebarRow = (attribute) => (
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
}: AttributeListProps) => {
  const [expanded, setExpanded] = React.useState<boolean>(false);

  const expand = React.useCallback(event => {
    event.preventDefault();
    setExpanded(true);
  });

  const collapse = React.useCallback(event => {
    event.preventDefault();
    setExpanded(false);
  });

  const tooManyEvents = attributes
    ? attributes.length >= TO_TRIGGER_COLLAPSE
    : false;

  return (
    (attributes?.length) ? (
      <>
        {(tooManyEvents && !expanded) ? (
          <>
            {attributes.slice(0, TO_SHOW_BEFORE).map(
              attribute => isSidebar
                ? buildAttributeSidebarRow(attribute)
                : buildAttributeListRow(attribute),
            )}
            <p className="show-all" key="show-all">
              <a
                href="#"
                onClick={expand}
                role="button"
                title={l('Show all attributes')}
              >
                {bracketedText(texp.l('show {n} more', {
                  n: attributes.length - (TO_SHOW_BEFORE + TO_SHOW_AFTER),
                }))}
              </a>
            </p>
            {attributes.slice(-TO_SHOW_AFTER).map(
              attribute => isSidebar
                ? buildAttributeSidebarRow(attribute)
                : buildAttributeListRow(attribute),
            )}
          </>
        ) : (
          <>
            {attributes.map(attribute => isSidebar
              ? buildAttributeSidebarRow(attribute)
              : buildAttributeListRow(attribute))}
            {tooManyEvents && expanded ? (
              <p className="show-less" key="show-less">
                <a
                  href="#"
                  onClick={collapse}
                  role="button"
                  title={l('Show less attributes')}
                >
                  {bracketedText(l('show less'))}
                </a>
              </p>
            ) : null}
          </>
        )}
      </>
    ) : null
  );
};

export default (hydrate<AttributeListProps>(
  'div.entity-attributes-container',
  AttributeList,
): React.AbstractComponent<AttributeListProps, void>);
