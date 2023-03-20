/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';

type Props = {
  +edit: AddAreaEditT,
};

const AddArea = ({edit}: Props): React$MixedElement => {
  const display = edit.display_data;
  const areaType = display.type;

  return (
    <>
      <table className="details">
        <tr>
          <th>{addColonText(l('Area'))}</th>
          <td>
            <DescriptiveLink
              entity={display.area}
            />
          </td>
        </tr>
      </table>

      <table className="details add-area">
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>

        {nonEmpty(display.sort_name) ? (
          <tr>
            <th>{addColonText(l('Sort name'))}</th>
            <td>{display.sort_name}</td>
          </tr>
        ) : null}

        {nonEmpty(display.comment) ? (
          <tr>
            <th>{addColonText(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        {areaType ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(areaType.name, 'area_type')}</td>
          </tr>
        ) : null}

        {display.iso_3166_1 ? (
          <tr>
            <th>{addColonText(l('ISO 3166-1'))}</th>
            <td>{commaOnlyListText(display.iso_3166_1)}</td>
          </tr>
        ) : null}

        {display.iso_3166_2 ? (
          <tr>
            <th>{addColonText(l('ISO 3166-2'))}</th>
            <td>{commaOnlyListText(display.iso_3166_2)}</td>
          </tr>
        ) : null}

        {display.iso_3166_3 ? (
          <tr>
            <th>{addColonText(l('ISO 3166-3'))}</th>
            <td>{commaOnlyListText(display.iso_3166_3)}</td>
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

        <tr>
          <th>{addColonText(l('Ended'))}</th>
          <td>{yesNo(display.ended)}</td>
        </tr>
      </table>
    </>
  );
};

export default AddArea;
