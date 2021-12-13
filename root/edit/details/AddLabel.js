/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import formatDate from '../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import yesNo from '../../static/scripts/common/utility/yesNo';
import formatIsni from '../../utility/formatIsni';

type Props = {
  +allowNew?: boolean,
  +edit: AddLabelEditT,
};

const AddLabel = ({allowNew, edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const type = display.type;
  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColonText(l('Label'))}</th>
            <td>
              <EntityLink allowNew={allowNew} entity={display.label} />
            </td>
          </tr>
        </tbody>
      </table>
      <table className="details add-label">
        <tbody>
          <tr>
            <th>{addColonText(l('Name'))}</th>
            <td>{display.name}</td>
          </tr>

          {display.sort_name ? (
            <tr>
              <th>{addColonText(l('Sort name'))}</th>
              <td>{display.sort_name}</td>
            </tr>
          ) : null}

          {display.comment ? (
            <tr>
              <th>{addColonText(l('Disambiguation'))}</th>
              <td>{display.comment}</td>
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

          {display.area ? (
            <tr>
              <th>{addColonText(l('Area'))}</th>
              <td><DescriptiveLink entity={display.area} /></td>
            </tr>
          ) : null}

          {type ? (
            <tr>
              <th>{addColonText(l('Type'))}</th>
              <td>{lp_attributes(type.name, 'label_type')}</td>
            </tr>
          ) : null}

          {display.label_code == null ? null : (
            <tr>
              <th>{addColonText(l('Label code'))}</th>
              <td>{display.label_code}</td>
            </tr>
          )}

          {display.ipi_codes?.length ? (
            display.ipi_codes.map(ipi => (
              <tr key={ipi}>
                <th>{addColonText(l('IPI code'))}</th>
                <td>{ipi}</td>
              </tr>
            ))
          ) : null}

          {display.isni_codes?.length ? (
            display.isni_codes.map(isni => (
              <tr key={isni}>
                <th>{addColonText(l('ISNI code'))}</th>
                <td>{formatIsni(isni)}</td>
              </tr>
            ))
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddLabel;
