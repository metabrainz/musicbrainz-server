/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {
  artistBeginAreaLabel,
  artistBeginLabel,
  artistEndAreaLabel,
  artistEndLabel,
} from '../../artist/utils';
import formatDate from '../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty';
import DescriptiveLink from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import yesNo from '../../static/scripts/common/utility/yesNo';
import formatIsni from '../../utility/formatIsni';

type AddArtistEditT = {|
  ...EditT,
  +display_data: {|
    ...CommentRoleT,
    ...DatePeriodRoleT,
    +area: AreaT | null,
    +artist: AreaT,
    +begin_area: AreaT | null,
    +end_area: AreaT | null,
    +gender: GenderT | null,
    +ipi_codes: $ReadOnlyArray<string> | null,
    +isni_codes: $ReadOnlyArray<string> | null,
    +name: string,
    +sort_name: string,
    +type: ArtistTypeT | null,
  |},
|};

const AddArtist = ({edit}: {edit: AddArtistEditT}) => {
  const display = edit.display_data;
  const gender = display.gender;
  const type = display.type;

  return (
    <>
      <table className="details">
        <tbody>
          <tr>
            <th>{addColon(l('Artist'))}</th>
            <td>
              <EntityLink
                allowNew
                entity={display.artist}
              />
            </td>
          </tr>
        </tbody>
      </table>

      <table className="details add-artist">
        <tbody>
          <tr>
            <th>{addColon(l('Name'))}</th>
            <td>{display.name}</td>
          </tr>

          <tr>
            <th>{addColon(l('Sort name'))}</th>
            <td>{display.sort_name}</td>
          </tr>

          {display.comment ? (
            <tr>
              <th>{addColon(l('Disambiguation'))}</th>
              <td>{display.comment}</td>
            </tr>
          ) : null}

          {type ? (
            <tr>
              <th>{addColon(l('Type'))}</th>
              <td>{lp_attributes(type.name, 'artist_type')}</td>
            </tr>
          ) : null}

          {gender ? (
            <tr>
              <th>{addColon(l('Gender'))}</th>
              <td>{lp_attributes(gender.name, 'gender')}</td>
            </tr>
          ) : null}

          {display.area.gid ? (
            <tr>
              <th>{addColon(l('Area'))}</th>
              <td>
                <DescriptiveLink
                  entity={display.area}
                />
              </td>
            </tr>
          ) : null}

          {isDateEmpty(display.begin_date) ? null : (
            <tr>
              <th>{artistBeginLabel(type ? type.id : null)}</th>
              <td>{formatDate(display.begin_date)}</td>
            </tr>
          )}

          {display.begin_area.gid ? (
            <tr>
              <th>{artistBeginAreaLabel(type ? type.id : null)}</th>
              <td>
                <DescriptiveLink
                  entity={display.begin_area}
                />
              </td>
            </tr>
          ) : null}

          {isDateEmpty(display.end_date) ? null : (
            <tr>
              <th>{artistEndLabel(type ? type.id : null)}</th>
              <td>{formatDate(display.end_date)}</td>
            </tr>
          )}

          {display.end_area.gid ? (
            <tr>
              <th>{artistEndAreaLabel(type ? type.id : null)}</th>
              <td>
                <DescriptiveLink
                  entity={display.end_area}
                />
              </td>
            </tr>
          ) : null}

          <tr>
            <th>{addColon(l('Ended'))}</th>
            <td>{yesNo(display.ended)}</td>
          </tr>

          {display.ipi_codes && display.ipi_codes.length > 0 ? (
            display.ipi_codes.map(ipi => (
              <tr key={ipi}>
                <th>{addColon(l('IPI code'))}</th>
                <td>{ipi}</td>
              </tr>
            ))
          ) : null}

          {display.isni_codes && display.isni_codes.length > 0 ? (
            display.isni_codes.map(isni => (
              <tr key={isni}>
                <th>{addColon(l('ISNI code'))}</th>
                <td>{formatIsni(isni)}</td>
              </tr>
            ))
          ) : null}
        </tbody>
      </table>
    </>
  );
};

export default AddArtist;
