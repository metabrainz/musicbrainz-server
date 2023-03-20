/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink, {DeletedLink}
  from '../../../static/scripts/common/components/EntityLink.js';
import formatDate from '../../../static/scripts/common/utility/formatDate.js';

type Props = {
  +edit: EditReleaseEventsHistoricEditT,
};

function buildEventComp(
  event: OldReleaseEventCompT,
  key: string,
): React$Element<'tr'> {
  return (
    <tr key={key}>
      <td>
        {event.release
          ? <EntityLink entity={event.release} />
          : <DeletedLink allowNew={false} name={null} />}
      </td>
      <td>
        {formatDate(event.date.old)}
        <br />
        {formatDate(event.date.new)}
      </td>
      <td>
        {event.country?.old
          ? <EntityLink entity={event.country.old} />
          : null}
        <br />
        {event.country?.new
          ? <EntityLink entity={event.country.new} />
          : null}
      </td>
      <td>
        {event.label?.old
          ? <EntityLink entity={event.label.old} />
          : null}
        <br />
        {event.label?.new
          ? <EntityLink entity={event.label.new} />
          : null}
      </td>
      <td>
        {event.catalog_number.old}
        <br />
        {event.catalog_number.new}
      </td>
      <td>
        {event.barcode.old}
        <br />
        {event.barcode.new}
      </td>
      <td>
        {event.format?.old
          ? lp_attributes(event.format.old.name, 'medium_format')
          : null}
        <br />
        {event.format?.new
          ? lp_attributes(event.format.new.name, 'medium_format')
          : null}
      </td>
    </tr>
  );
}

function buildEvent(
  event: OldReleaseEventT,
  key: string,
): React$Element<'tr'> {
  return (
    <tr key={key}>
      <td>
        {event.release
          ? <EntityLink entity={event.release} />
          : <DeletedLink allowNew={false} name={null} />}
      </td>
      <td>{formatDate(event.date)}</td>
      <td>
        {event.country ? <EntityLink entity={event.country} /> : null}
      </td>
      <td>
        {event.label ? <EntityLink entity={event.label} /> : null}
      </td>
      <td>{event.catalog_number}</td>
      <td>{event.barcode}</td>
      <td>
        {event.format
          ? lp_attributes(event.format.name, 'medium_format')
          : null}
      </td>
    </tr>
  );
}

const EditReleaseEvents = ({edit}: Props): React$Element<'table'> => (
  <table className="tbl edit-release-events">
    <thead>
      <tr>
        <th>{l('Release')}</th>
        <th>{l('Date')}</th>
        <th>{l('Country')}</th>
        <th>{l('Label')}</th>
        <th>{l('Catalog number')}</th>
        <th>{l('Barcode')}</th>
        <th>{l('Format')}</th>
      </tr>
    </thead>
    {edit.display_data.additions.length ? (
      <>
        <thead>
          <tr>
            <th colSpan="7">{l('Added')}</th>
          </tr>
        </thead>
        <tbody>
          {edit.display_data.additions.map(
            (event, index) => buildEvent(event, 'additions' + index),
          )}
        </tbody>
      </>
    ) : null}
    {edit.display_data.removals.length ? (
      <>
        <thead>
          <tr>
            <th colSpan="7">{l('Removed')}</th>
          </tr>
        </thead>
        <tbody>
          {edit.display_data.removals.map(
            (event, index) => buildEvent(event, 'removals' + index),
          )}
        </tbody>
      </>
    ) : null}
    {edit.display_data.edits.length ? (
      <>
        <thead>
          <tr>
            <th colSpan="7">{l('Edited')}</th>
          </tr>
        </thead>
        <tbody>
          {edit.display_data.edits.map(
            (event, index) => buildEventComp(event, 'edits' + index),
          )}
        </tbody>
      </>
    ) : null}
  </table>
);

export default EditReleaseEvents;
