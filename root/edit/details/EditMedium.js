/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink.js';
import DataTrackIcon
  from '../../static/scripts/common/components/DataTrackIcon.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import EntityLink
  from '../../static/scripts/common/components/EntityLink.js';
import ExpandedArtistCredit
  from '../../static/scripts/common/components/ExpandedArtistCredit.js';
import MediumLink
  from '../../static/scripts/common/components/MediumLink.js';
import PregapTrackIcon
  from '../../static/scripts/common/components/PregapTrackIcon.js';
import {artistCreditsAreEqual}
  from '../../static/scripts/common/immutable-entities.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import DiffSide from '../../static/scripts/edit/components/edit/DiffSide.js';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import InformationIcon
  from '../../static/scripts/edit/components/InformationIcon.js';
import diffArtistCredits
  from '../../static/scripts/edit/utility/diffArtistCredits.js';
import {DELETE, INSERT} from '../../static/scripts/edit/utility/editDiff.js';
import loopParity from '../../utility/loopParity.js';

component ChangedMbidIcon() {
  return (
    <InformationIcon
      title={l("This track's MBID will change when this edit is applied.")}
    />
  );
}

component TracklistChangesAdd(
  change: TracklistChangesAddT,
  changedMbids: boolean,
) {
  const track = change.new_track;
  return (
    <tr className="diff-addition edit-medium-track">
      <td colSpan="4" />
      <td className="pos t">
        {track.number}
      </td>
      <td>
        {track.position === 0 ? (
          <>
            <PregapTrackIcon />
            {' '}
          </>
        ) : null}
        {track.isDataTrack ? (
          <>
            <DataTrackIcon />
            {' '}
          </>
        ) : null}
        {/* If no recording_id exists, it's creating a recording */}
        <EntityLink
          allowNew={track && !track.recording.id}
          content={track.name}
          entity={track.recording}
        />
      </td>
      <td>
        <ArtistCreditLink artistCredit={track.artistCredit} />
      </td>
      <td>
        {formatTrackLength(track.length)}
      </td>
      {changedMbids ? (
        <td>
          {track.id ? null : <ChangedMbidIcon />}
        </td>
      ) : null}
    </tr>
  );
}

component TracklistChangesChange(
  change: TracklistChangesChangeT,
  changedMbids: boolean,
  index: number,
) {
  const oldTrack = change.old_track;
  const newTrack = change.new_track;
  const artistCreditDiff = diffArtistCredits(
    oldTrack.artistCredit,
    newTrack.artistCredit,
  );
  const newNumberDiff = (
    <DiffSide
      filter={INSERT}
      newText={newTrack.number.toString()}
      oldText={oldTrack.number.toString()}
      split="\s+"
    />
  );
  const oldNumberDiff = (
    <DiffSide
      filter={DELETE}
      newText={newTrack.number.toString()}
      oldText={oldTrack.number.toString()}
      split="\s+"
    />
  );
  const newNameDiff = (
    <DiffSide
      filter={INSERT}
      newText={newTrack.name || ''}
      oldText={oldTrack.name || ''}
      split="\s+"
    />
  );
  const oldNameDiff = (
    <DiffSide
      filter={DELETE}
      newText={newTrack.name || ''}
      oldText={oldTrack.name || ''}
      split="\s+"
    />
  );
  const newLengthDiff = (
    <DiffSide
      filter={INSERT}
      newText={formatTrackLength(newTrack.length)}
      oldText={formatTrackLength(oldTrack.length)}
      split="\s+"
    />
  );
  const oldLengthDiff = (
    <DiffSide
      filter={DELETE}
      newText={formatTrackLength(newTrack.length)}
      oldText={formatTrackLength(oldTrack.length)}
      split="\s+"
    />
  );

  return (
    <tr className={'edit-medium-track ' + loopParity(index)}>
      <td className="pos t">
        {oldNumberDiff}
      </td>
      <td>
        {oldTrack.position === 0 ? (
          <>
            <PregapTrackIcon />
            {' '}
          </>
        ) : null}
        {oldTrack.isDataTrack ? (
          <>
            <DataTrackIcon />
            {' '}
          </>
        ) : null}
        <EntityLink
          content={oldNameDiff}
          entity={oldTrack.recording}
          nameVariation={oldTrack.name !== oldTrack.recording.name}
        />
      </td>
      <td>
        {artistCreditDiff.old}
      </td>
      <td className="treleases">
        {oldLengthDiff}
      </td>
      <td className="pos t">
        {newNumberDiff}
      </td>
      <td>
        {newTrack.position === 0 ? (
          <>
            <PregapTrackIcon />
            {' '}
          </>
        ) : null}
        {newTrack.isDataTrack ? (
          <>
            <DataTrackIcon />
            {' '}
          </>
        ) : null}
        {/* If no recording_id exists, it's creating a recording */}
        <EntityLink
          allowNew={newTrack && !newTrack.recording.id}
          content={newNameDiff}
          entity={newTrack.recording}
          nameVariation={newTrack.name !== newTrack.recording.name}
        />
      </td>
      <td>
        {artistCreditDiff.new}
      </td>
      <td className="treleases">
        {newLengthDiff}
      </td>
      {changedMbids ? (
        <td>
          {newTrack.id ? null : <ChangedMbidIcon />}
        </td>
      ) : null}
    </tr>
  );
}

component TracklistChangesRemove(
  change: TracklistChangesRemoveT,
  changedMbids: boolean,
) {
  const track = change.old_track;
  return (
    <tr className="diff-removal edit-medium-track">
      <td className="pos t">
        {track.number}
      </td>
      <td>
        {track.position === 0 ? (
          <>
            <PregapTrackIcon />
            {' '}
          </>
        ) : null}
        {track.isDataTrack ? (
          <>
            <DataTrackIcon />
            {' '}
          </>
        ) : null}
        <EntityLink
          content={track.name}
          entity={track.recording}
        />
      </td>
      <td>
        <ArtistCreditLink artistCredit={track.artistCredit} />
      </td>
      <td>
        {formatTrackLength(track.length)}
      </td>
      <td colSpan={changedMbids ? '5' : '4'} />
    </tr>
  );
}

component TracklistChangesTable (
  changedMbids: boolean,
  changes: $ReadOnlyArray<
    | TracklistChangesAddT
    | TracklistChangesChangeT
    | TracklistChangesRemoveT>,
) {
  return (
    <table className="tbl">
      <thead>
        <tr>
          <th colSpan="4">{l('Old tracklist')}</th>
          <th colSpan="4">{l('New tracklist')}</th>
          {changedMbids ? <th /> : null}
        </tr>
        <tr>
          <th>{l('#')}</th>
          <th>{l('Title')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Length')}</th>
          <th>{l('#')}</th>
          <th>{l('Title')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Length')}</th>
          {changedMbids ? <th /> : null}
        </tr>
      </thead>
      <tbody>
        {changes.map((change, index) => {
          if (change.change_type === 'c' || change.change_type === 'u') {
            return (
              <TracklistChangesChange
                change={change}
                changedMbids={changedMbids}
                index={index}
                key={index}
              />
            );
          } else if (change.change_type === '+') {
            return (
              <TracklistChangesAdd
                change={change}
                changedMbids={changedMbids}
                key={index}
              />
            );
          } else if (change.change_type === '-') {
            return (
              <TracklistChangesRemove
                change={change}
                changedMbids={changedMbids}
                key={index}
              />
            );
          }
          return null;
        })}
      </tbody>
    </table>
  );
}

component CondensedTrackACsDiffRow(
  endNumber?: string,
  newArtistCredit: ArtistCreditT,
  oldArtistCredit?: ArtistCreditT,
  rowCounter: number,
  startNumber: string,
) {
  return (
    <tr className={loopParity(rowCounter)}>
      <td className="pos t">
        {nonEmpty(endNumber) && endNumber !== startNumber
          ? startNumber + '-' + endNumber
          : startNumber}
      </td>
      <td>
        {oldArtistCredit ? (
          <ExpandedArtistCredit artistCredit={oldArtistCredit} />
        ) : null}
      </td>
      <td>
        {newArtistCredit ? (
          <ExpandedArtistCredit artistCredit={newArtistCredit} />
        ) : null}
      </td>
    </tr>
  );
}

component CondensedTrackACsDiff(
  artistCreditChanges: $ReadOnlyArray<
    | TracklistChangesAddT
    | TracklistChangesChangeT>,
) {
  let thisOldCredit;
  let thisNewCredit;
  let thisPosition = 0;
  let rowCounter = 1;
  let startNumber = artistCreditChanges[0].new_track.number;
  let endNumber;
  const rows = [];

  artistCreditChanges.forEach((change, index, array) => {
    const isLast = array.length - 1 === index;
    const oldTrack = change.old_track;
    const newTrack = change.new_track;
    const isNewOldArtistCredit = Boolean(oldTrack && thisOldCredit &&
      !artistCreditsAreEqual(thisOldCredit, oldTrack.artistCredit));
    const isNewNewArtistCredit = Boolean(thisNewCredit &&
      !artistCreditsAreEqual(thisNewCredit, newTrack.artistCredit));
    const isTherePositionGap = thisPosition + 1 !== +newTrack.position;
    const isThereMeaningfulPositionGap = isTherePositionGap &&
      (thisOldCredit || thisNewCredit);
    const startNewRow = isNewOldArtistCredit ||
      isNewNewArtistCredit ||
      isThereMeaningfulPositionGap;
    if (startNewRow) {
      rows.push(
        <CondensedTrackACsDiffRow
          endNumber={endNumber}
          newArtistCredit={thisNewCredit}
          oldArtistCredit={thisOldCredit}
          rowCounter={rowCounter}
          startNumber={startNumber}
        />,
      );
      rowCounter++;
      startNumber = newTrack.number;
      endNumber = startNumber;
    } else {
      endNumber = newTrack.number;
    }
    thisOldCredit = oldTrack?.artistCredit;
    thisNewCredit = newTrack.artistCredit;
    thisPosition = +newTrack.position;
    if (isLast) {
      rows.push(
        <CondensedTrackACsDiffRow
          endNumber={endNumber}
          newArtistCredit={thisNewCredit}
          oldArtistCredit={thisOldCredit}
          rowCounter={rowCounter}
          startNumber={startNumber}
        />,
      );
    }
  });
  return rows;
}

component EditMedium(edit: EditMediumEditT) {
  const display = edit.display_data;
  const artistCreditChanges = display.artist_credit_changes;
  const changedDataTracks = display.data_track_changes;
  const changedMbids = display.changed_mbids;
  const format = display.format;
  const name = display.name;
  const position = display.position;
  const recordingChanges = display.recording_changes;
  const tracklistChanges = display.tracklist_changes;

  return (
    <table className="details edit-medium">
      <tr>
        <th>{addColonText(l('Medium'))}</th>
        <td colSpan="2">
          <MediumLink medium={display.medium} />
        </td>
      </tr>

      {position ? (
        <FullChangeDiff
          label={addColonText(l('Position'))}
          newContent={position.new}
          oldContent={position.old || ''}
        />
      ) : null}

      {name ? (
        <WordDiff
          label={addColonText(l('Name'))}
          newText={name.new || ''}
          oldText={name.old || ''}
        />
      ) : null}

      {format ? (
        <FullChangeDiff
          label={addColonText(l('Format'))}
          newContent={format.new
            ? lp_attributes(format.new.name, 'medium_format')
            : ''}
          oldContent={format.old
            ? lp_attributes(format.old.name, 'medium_format')
            : ''}
        />
      ) : null}

      {tracklistChanges?.length ? (
        <tr>
          <th>{addColonText(l('Tracklist'))}</th>
          <td colSpan="2">
            <TracklistChangesTable
              changedMbids={changedMbids}
              changes={tracklistChanges}
            />
            {changedDataTracks ? (
              <p>
                {l('This edit changes which tracks are data tracks.')}
              </p>
            ) : null}
          </td>
        </tr>
      ) : null}

      {recordingChanges?.length ? (
        <tr>
          <th>{addColonText(l('Recordings'))}</th>
          <td colSpan="2">
            <table className="tbl">
              <thead>
                <tr>
                  <th className="pos">{l('#')}</th>
                  <th>{l('Old recording')}</th>
                  <th>{l('New recording')}</th>
                </tr>
              </thead>
              <tbody>
                {recordingChanges.map((change, index) => {
                  const oldTrack = change.old_track;
                  const oldArtistCredit = oldTrack?.recording?.artistCredit ??
                    oldTrack?.artistCredit;
                  const newTrack = change.new_track;
                  const newArtistCredit = newTrack.recording.artistCredit ??
                    newTrack.artistCredit;
                  const allowNew = newTrack && !newTrack.recording.id;

                  return (
                    <tr className={loopParity(index)} key={newTrack.id}>
                      <td className="pos t">
                        <span style={{display: 'none'}}>
                          {newTrack.position}
                        </span>
                        {newTrack.number}
                      </td>
                      <td>
                        <span className="diff-only-a">
                          {oldTrack ? (
                            <DescriptiveLink
                              customArtistCredit={oldArtistCredit}
                              entity={oldTrack.recording}
                            />
                          ) : null}
                        </span>
                      </td>
                      <td>
                        <span className="diff-only-b">
                          <DescriptiveLink
                            allowNew={allowNew}
                            customArtistCredit={newArtistCredit}
                            entity={newTrack.recording}
                          />
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </td>
        </tr>
      ) : null}

      {artistCreditChanges?.length ? (
        <tr>
          <th>{addColonText(l('Artist credits'))}</th>
          <td colSpan="2">
            <table className="tbl">
              <thead>
                <tr>
                  <th className="pos">{l('#')}</th>
                  <th>{l('Old artist')}</th>
                  <th>{l('New artist')}</th>
                </tr>
              </thead>
              <tbody>
                <CondensedTrackACsDiff
                  artistCreditChanges={artistCreditChanges}
                />
              </tbody>
            </table>
          </td>
        </tr>
      ) : null}
    </table>
  );
}

export default EditMedium;
