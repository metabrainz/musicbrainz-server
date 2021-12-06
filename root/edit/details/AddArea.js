/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';
import formatDate from '../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import yesNo from '../../static/scripts/common/utility/yesNo';

type Props = {
  +edit: AddAreaEditT,
};

const AddArea = ({edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const areaType = display.type;

  return (
    <>
      <table className="details">
        <tr>
          <th>{addColon(l('Area'))}</th>
          <td>
            <DescriptiveLink
              entity={display.area}
            />
          </td>
        </tr>
      </table>

      <table className="details add-area">
        <tr>
          <th>{addColon(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>

        {nonEmpty(display.sort_name) ? (
          <tr>
            <th>{addColon(l('Sort name'))}</th>
            <td>{display.sort_name}</td>
          </tr>
        ) : null}

        {nonEmpty(display.comment) ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        {areaType ? (
          <tr>
            <th>{addColon(l('Type'))}</th>
            <td>{lp_attributes(areaType.name, 'area_type')}</td>
          </tr>
        ) : null}

        {display.iso_3166_1 ? (
          <tr>
            <th>{addColon(l('ISO 3166-1'))}</th>
            <td>{commaOnlyList(display.iso_3166_1)}</td>
          </tr>
        ) : null}

        {display.iso_3166_2 ? (
          <tr>
            <th>{addColon(l('ISO 3166-2'))}</th>
            <td>{commaOnlyList(display.iso_3166_2)}</td>
          </tr>
        ) : null}

        {display.iso_3166_3 ? (
          <tr>
            <th>{addColon(l('ISO 3166-3'))}</th>
            <td>{commaOnlyList(display.iso_3166_3)}</td>
          </tr>
        ) : null}

        {isDateEmpty(display.begin_date) ? null : (
          <tr>
            <th>{addColon(l('Begin date'))}</th>
            <td>{formatDate(display.begin_date)}</td>
          </tr>
        )}

        {isDateEmpty(display.end_date) ? null : (
          <tr>
            <th>{addColon(l('End date'))}</th>
            <td>{formatDate(display.end_date)}</td>
          </tr>
        )}

        <tr>
          <th>{addColon(l('Ended'))}</th>
          <td>{yesNo(display.ended)}</td>
        </tr>
      </table>
    </>
  );
};

export default AddArea;
