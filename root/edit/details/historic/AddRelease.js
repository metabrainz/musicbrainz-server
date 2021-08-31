/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import HistoricReleaseList
  from '../../components/HistoricReleaseList';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink';
import formatDate
  from '../../../static/scripts/common/utility/formatDate';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength';

type AddReleaseEditT = {
  ...EditT,
  +display_data: {
    +artist: ArtistT,
    +language: LanguageT | null,
    +name: string,
    +release_events: $ReadOnlyArray<{
      +barcode: number,
      +catalog_number: string | null,
      +country: AreaT | null,
      +date: PartialDateT | null,
      +format: MediumFormatT | null,
      +label: LabelT | null,
    }>,
    +releases: $ReadOnlyArray<ReleaseT | null>,
    +script: ScriptT | null,
    +status: ReleaseStatusT | null,
    +tracks: $ReadOnlyArray<{
      +artist: ArtistT,
      +length: number | null,
      +name: string,
      +position: number,
      +recording: RecordingT,
    }>,
    +type: ReleaseGroupTypeT | null,
  },
};

type Props = {
  +edit: AddReleaseEditT,
};

const AddRelease = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const artist = display.artist;
  const type = display.type;

  return (
    <table className="details add-release">
      <HistoricReleaseList releases={display.releases} />

      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>{display.name}</td>
      </tr>

      <tr>
        <th>{addColonText(l('Artist'))}</th>
        <td>
          <EntityLink entity={artist} />
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Type'))}</th>
        <td>
          {type
            ? type.historic
              ? lp_attributes(type.name, 'release_group_secondary_type')
              : lp_attributes(type.name, 'release_group_primary_type')
            : null}
        </td>
      </tr>

      <tr>
        <th>{lp('Status:', 'release status')}</th>
        <td>
          {display.status
            ? lp_attributes(display.status.name, 'release_status')
            : null}
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Script'))}</th>
        <td>
          {display.script
            ? l_scripts(display.script.name)
            : null}
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Language'))}</th>
        <td>
          {display.language
            ? l_languages(display.language.name)
            : null}
        </td>
      </tr>

      <tr>
        <th>{addColonText(l('Tracks'))}</th>
        <td>
          <table className="tbl">
            <thead>
              <tr>
                <th>{l('#')}</th>
                <th>{l('Name')}</th>
                <th>{l('Artist')}</th>
                <th>{l('Length')}</th>
              </tr>
            </thead>
            <tbody>
              {display.tracks.map((track, index) => (
                <tr key={'track-' + index}>
                  <td>{track.position}</td>
                  <td>
                    <EntityLink
                      content={track.name}
                      entity={track.recording}
                    />
                  </td>
                  <td>
                    <EntityLink entity={track.artist} />
                  </td>
                  <td>{formatTrackLength(track.length)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </td>
      </tr>

      <tr>
        <th>{l('Release Events:')}</th>
        <td>
          <table className="tbl">
            <thead>
              <tr>
                <th>{l('Date')}</th>
                <th>{l('Country')}</th>
                <th>{l('Label')}</th>
                <th>{l('Catalog Number')}</th>
                <th>{l('Barcode')}</th>
                <th>{l('Format')}</th>
              </tr>
            </thead>
            <tbody>
              {display.release_events.map((event, index) => (
                <tr key={'event-' + index}>
                  <td>{formatDate(event.date)}</td>
                  <td>
                    {event.country
                      ? <EntityLink entity={event.country} />
                      : null}
                  </td>
                  <td>
                    {event.label
                      ? <EntityLink entity={event.label} />
                      : null}
                  </td>
                  <td>{event.catalog_number}</td>
                  <td>{event.barcode}</td>
                  <td>
                    {event.format
                      ? lp_attributes(event.format.name, 'medium_format')
                      : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </td>
      </tr>
    </table>
  );
};

export default AddRelease;
