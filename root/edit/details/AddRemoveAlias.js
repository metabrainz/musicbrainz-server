/*
 * @flow
 * Copyright (C) 2019 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import locales from '../../static/scripts/common/constants/locales.json';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty.js';
import isolateText from '../../static/scripts/common/utility/isolateText.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';

type Props = {
  edit: AddRemoveAliasEditT,
};

const AddRemoveAlias = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const entityType = display.entity_type;
  const entity = display[entityType];
  const entityWithGid = entity?.gid ? entity : null;
  const ended = display.ended;
  const type = display.type;

  return (
    <table className={`details ${edit.edit_kind}-${entityType}-alias`}>
      <tbody>
        <tr>
          <th>{addColonText(formatEntityTypeName(entityType))}</th>
          <td>
            <DescriptiveLink entity={entity} />
            {entityWithGid ? (
              <>
                {' '}
                {bracketed(
                  <EntityLink
                    content={l('view all aliases')}
                    entity={entityWithGid}
                    subPath="aliases"
                  />,
                )}
              </>
            ) : null}
          </td>
        </tr>

        <tr>
          <th>{addColonText(l('Alias'))}</th>
          <td>{isolateText(display.alias)}</td>
        </tr>

        {display.sort_name ? (
          <tr>
            <th>{addColonText(l('Sort name'))}</th>
            <td>{display.sort_name}</td>
          </tr>
        ) : null}

        {display.locale ? (
          <>
            <tr>
              <th>{addColonText(l('Locale'))}</th>
              <td>{locales[display.locale]}</td>
            </tr>
            <tr>
              <th>{addColonText(l('Primary for locale'))}</th>
              <td>{yesNo(display.primary_for_locale)}</td>
            </tr>
          </>
        ) : null}

        {type ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(type.name, 'alias_type')}</td>
          </tr>
        ) : null}

        {isDateEmpty(display.begin_date) ? null : (
          <tr>
            <th>{addColonText(l('Begin date'))}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        )}

        {isDateEmpty(display.end_date) ? null : (
          <tr>
            <th>{addColonText(l('End date'))}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        )}

        {ended == null ? null : (
          <tr>
            <th>{addColonText(l('Ended'))}</th>
            <td>{yesNo(ended)}</td>
          </tr>
        )}
      </tbody>
    </table>
  );
};

export default AddRemoveAlias;
