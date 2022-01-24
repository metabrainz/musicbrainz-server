/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import IntentionallyRawIcon from '../components/IntentionallyRawIcon';
import {ENTITY_NAMES} from '../../static/scripts/common/constants';

type Props = {
  +edit: RemoveRelationshipTypeEditT,
};

const RemoveRelationshipType = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const entity0Type = ENTITY_NAMES[display.entity0_type]();
  const entity1Type = ENTITY_NAMES[display.entity1_type]();

  // Always display entity placeholders for ease of understanding
  let longLinkPhrase = display.long_link_phrase;
  if (longLinkPhrase && !longLinkPhrase.includes('{entity0}')) {
    longLinkPhrase = '{entity0} ' + longLinkPhrase;
  }
  if (longLinkPhrase && !longLinkPhrase.includes('{entity1}')) {
    longLinkPhrase += ' {entity1}';
  }

  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <table className="details remove-relationship-type">
      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>
          {display.name}
          {rawIconSection}
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Description'))}</th>
        <td>
          {nonEmpty(display.description)
            ? (
              <>
                {display.description}
                {rawIconSection}
              </>
            ) : lp('(none)', 'description')}
        </td>
      </tr>

      <tr>
        <th>
          {addColon(exp.l('Type of {entity_placeholder}', {
            entity_placeholder: <code>{'{entity0}'}</code>,
          }))}
        </th>
        <td>{entity0Type}</td>
      </tr>

      <tr>
        <th>
          {addColon(exp.l('Type of {entity_placeholder}', {
            entity_placeholder: <code>{'{entity1}'}</code>,
          }))}
        </th>
        <td>{entity1Type}</td>
      </tr>

      <tr>
        <th>{l('Link phrase:')}</th>
        <td>
          {display.link_phrase ? (
            <>
              {display.link_phrase}
              {rawIconSection}
            </>
          ) : lp('(none)', 'link_phrase')}
        </td>
      </tr>

      <tr>
        <th>{l('Reverse link phrase:')}</th>
        <td>
          {display.reverse_link_phrase ? (
            <>
              {display.reverse_link_phrase}
              {rawIconSection}
            </>
          ) : lp('(none)', 'link_phrase')}
        </td>
      </tr>

      <tr>
        <th>{l('Long link phrase:')}</th>
        <td>
          {longLinkPhrase ? (
            <>
              {longLinkPhrase}
              {rawIconSection}
            </>
          ) : lp('(none)', 'link_phrase')}
        </td>
      </tr>

      {display.attributes.length > 0 ? (
        <tr>
          <th>{addColonText(l('Attributes'))}</th>
          <td>
            <ul>
              {display.attributes.map((attribute, index) => (
                <li key={'attribute-' + index}>
                  {addColonText(l_relationships(attribute.typeName))}
                  {' '}
                  {attribute.min}
                  {'-'}
                  {attribute.max}
                </li>
              ))}
            </ul>
          </td>
        </tr>
      ) : null}
    </table>
  );
};

export default RemoveRelationshipType;
