/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  artistBeginAreaLabel,
  artistBeginLabel,
  artistEndAreaLabel,
  artistEndLabel,
} from '../../artist/utils.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import formatDate from '../../static/scripts/common/utility/formatDate.js';
import isDateEmpty from '../../static/scripts/common/utility/isDateEmpty.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import formatIsni from '../../utility/formatIsni.js';

type Props = {
  +edit: AddArtistEditT,
};

const AddArtist = ({edit}: Props): React$MixedElement => {
  const display = edit.display_data;
  const area = display.area;
  const beginArea = display.begin_area;
  const endArea = display.end_area;
  const gender = display.gender;
  const type = display.type;

  return (
    <>
      <table className="details">
        <tr>
          <th>{addColonText(l('Artist'))}</th>
          <td>
            <EntityLink
              entity={display.artist}
            />
          </td>
        </tr>
      </table>

      <table className="details add-artist">
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>

        <tr>
          <th>{addColonText(l('Sort name'))}</th>
          <td>{display.sort_name}</td>
        </tr>

        {display.comment ? (
          <tr>
            <th>{addColonText(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        {type ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(type.name, 'artist_type')}</td>
          </tr>
        ) : null}

        {gender ? (
          <tr>
            <th>{addColonText(l('Gender'))}</th>
            <td>{lp_attributes(gender.name, 'gender')}</td>
          </tr>
        ) : null}

        {area ? (
          <tr>
            <th>{addColonText(l('Area'))}</th>
            <td>
              <DescriptiveLink
                entity={area}
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

        {beginArea ? (
          <tr>
            <th>{artistBeginAreaLabel(type ? type.id : null)}</th>
            <td>
              <DescriptiveLink
                entity={beginArea}
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

        {endArea ? (
          <tr>
            <th>{artistEndAreaLabel(type ? type.id : null)}</th>
            <td>
              <DescriptiveLink
                entity={endArea}
              />
            </td>
          </tr>
        ) : null}

        <tr>
          <th>{addColonText(l('Ended'))}</th>
          <td>{yesNo(display.ended)}</td>
        </tr>

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
      </table>
    </>
  );
};

export default AddArtist;
