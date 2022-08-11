/*
 * @flow strict-local
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink.js';

type Props = {
  +edit: AddSeriesEditT,
};

const AddSeries = ({edit}: Props): React.MixedElement => {
  const type = edit.display_data.type;
  const orderingType = edit.display_data.ordering_type;

  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Series'))}</th>
            <td><EntityLink entity={edit.display_data.series} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details add-series">
        <tbody>
          <tr>
            <th>{addColonText(l('Name'))}</th>
            <td>{edit.display_data.name}</td>
          </tr>
          {edit.display_data.comment ? (
            <tr>
              <th>{addColonText(l('Disambiguation'))}</th>
              <td>{edit.display_data.comment}</td>
            </tr>
          ) : null}
          {type ? (
            <tr>
              <th>{addColonText(l('Type'))}</th>
              <td>
                {lp_attributes(type.name, 'series_type')}
              </td>
            </tr>
          ) : null}
          {orderingType ? (
            <tr>
              <th>{addColonText(l('Ordering Type'))}</th>
              <td>
                {lp_attributes(orderingType.name, 'series_ordering_type')}
              </td>
            </tr>
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddSeries;
