import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import ExapandedArtistCredit from '../../components/ExpandedArtistCredit';
import formatTrackLength from '../../static/scripts/common/utility/formatTrackLength';
import yesNo from '../../static/scripts/common/utility/yesNo';

const AddStandaloneRecording = ({edit}) => {
  const display = edit.display_data;
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Recording:')}</th>
          <td><EntityLink entity={display.recording} /></td>
        </tr>
      </table>
      <table className="details add-standalone-recording">
        <tr>
          <th>{l('Name:')}</th>
          <td><EntityLink entity={display.recording} showDisambiguation content={display.name} /></td>
        </tr>
        <tr>
          <th>{l('Artist:')}</th>
          <td><ExapandedArtistCredit ac={display.artist_credit} /></td>
        </tr>
        {display.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}
        {display.length ? (
          <tr>
            <th>{l('Length:')}</th>
            <td>{formatTrackLength(display.length)}</td>
          </tr>
        ) : null}
        <tr>
          <th>{l('Video:')}</th>
          <td>{yesNo(display.video)}</td>
        </tr>
      </table>
    </>
  );
};

export default AddStandaloneRecording;
