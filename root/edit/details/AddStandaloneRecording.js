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
        <tbody>
          <tr>
            <th>{l('Recording:')}</th>
            <td><EntityLink allowNew entity={display.recording} /></td>
          </tr>
        </tbody>
      </table>
      <table className="details add-standalone-recording">
        <tbody>
          <tr>
            <th>{l('Name:')}</th>
            <td>
              <EntityLink
                allowNew
                content={display.name}
                entity={display.recording}
                showDisambiguation
              />
            </td>
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
        </tbody>
      </table>
    </>
  );
};

export default AddStandaloneRecording;
