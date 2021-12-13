/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import IntentionallyRawIcon
  from '../components/IntentionallyRawIcon';
import localizeLinkAttributeTypeName
  from '../../static/scripts/common/i18n/localizeLinkAttributeTypeName';
import yesNo from '../../static/scripts/common/utility/yesNo';

type Props = {
  +edit: AddRelationshipAttributeEditT,
};

const AddRelationshipAttribute = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const description = display.description;
  const parent = display.parent;
  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <table className="details add-relationship-attribute">
      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>
          {display.name}
          {rawIconSection}
        </td>
      </tr>
      {nonEmpty(description) ? (
        <tr>
          <th>{addColonText(l('Description'))}</th>
          <td>
            {description}
            {rawIconSection}
          </td>
        </tr>
      ) : null}
      <tr>
        <th>{addColonText(l('Child order'))}</th>
        <td>{display.child_order}</td>
      </tr>
      {parent ? (
        <tr>
          <th>{addColonText(l('Parent'))}</th>
          <td>{localizeLinkAttributeTypeName(parent)}</td>
        </tr>
      ) : null}
      <tr>
        <th>{addColonText(l('Creditable'))}</th>
        <td>{yesNo(display.creditable)}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Free text'))}</th>
        <td>{yesNo(display.free_text)}</td>
      </tr>
    </table>
  );
};

export default AddRelationshipAttribute;
