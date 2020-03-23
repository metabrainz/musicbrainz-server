/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditLink
  from '../../common/components/ArtistCreditLink';
import DescriptiveLink
  from '../../common/components/DescriptiveLink';
import EntityLink, {DeletedLink}
  from '../../common/components/EntityLink';
import {ExpandedArtistCreditList}
  from '../../common/components/ExpandedArtistCredit';
import Warning from '../../common/components/Warning';
import formatTrackLength
  from '../../common/utility/formatTrackLength';
import FormRowSelect from '../../../../components/FormRowSelect';
import hydrate from '../../../../utility/hydrate';
import loopParity from '../../../../utility/loopParity';

type Props = {
  +badRecordingMerges?:
    $ReadOnlyArray<$ReadOnlyArray<RecordingWithArtistCreditT>>,
  +form: MergeReleasesFormT,
  +mediums: $ReadOnlyArray<MediumT>,
  +releases: {[releaseID: number]: ReleaseT},
};

const MergeStrategyOptions = {
  grouped: false,
  options: [
    {label: N_l('Append mediums to target release'), value: 1},
    {label: N_l('Merge mediums and recordings'), value: 2},
  ],
};

const ReleaseMergeStrategy = ({
  badRecordingMerges,
  form,
  mediums,
  releases,
}: Props) => {
  const [mergeStrategy, setMergeStrategy] =
    React.useState(form.field.merge_strategy);

  function updateStrategy(event) {
    setMergeStrategy({
      ...mergeStrategy,
      value: parseInt(event.currentTarget.value, 10),
    });
  }

  const mediumsMap = form.field.medium_positions.field.map;
  return (
    <>
      <FormRowSelect
        field={mergeStrategy}
        hasHtmlErrors
        label={l('Merge strategy:')}
        onChange={updateStrategy}
        options={MergeStrategyOptions}
      />

      <div
        id="merge-strategy-1"
        style={mergeStrategy.value === 1 ? null : {display: 'none'}}
      >
        <p>
          {l(`Using this merge strategy, all mediums from all releases
              will be used. You may specify the new order of mediums.
              The order does not have to be continuous, but all medium
              positions must be positive, and multiple mediums
              cannot be in the same position`)}
        </p>
        <table className="tbl">
          <tbody>
            {mediums.map((medium, index) => {
              const mediumField = mediumsMap.field[index].field;

              return (
                <React.Fragment key={medium.id}>
                  <tr className="subh">
                    <th colSpan="4">
                      <label>{l('New position:')}</label>
                      {' '}
                      <input
                        defaultValue={mediumField.position.value}
                        size="2"
                        type="text"
                      />
                      {mediumField.position.has_errors ? (
                        <span
                          className="error"
                          style={{margin: '0 12px 0 6px'}}
                        >
                          {mediumField.position.errors[0]}
                        </span>
                      ) : null}
                      {' '}
                      <label>{l('New disc title:')}</label>
                      {' '}
                      <input
                        defaultValue={mediumField.name.value}
                        type="text"
                      />
                      <input
                        type="hidden"
                        value={mediumField.id.value}
                      />
                      <input
                        type="hidden"
                        value={mediumField.release_id.value}
                      />
                      {' '}
                      {medium.name ? (
                        exp.l(
                          `(was medium {position}: {name}
                          on release {release})`,
                          {
                            name: medium.name,
                            position: medium.position,
                            release: releases[medium.release_id].name,
                          },
                        )
                      ) : (
                        exp.l(
                          '(was medium {position} on release {release})',
                          {
                            position: medium.position,
                            release: releases[medium.release_id].name,
                          },
                        )
                      )}
                    </th>
                  </tr>
                  {medium.tracks ? medium.tracks.map((track, index) => (
                    <tr className={loopParity(index)} key={track.id}>
                      <td className="pos t">
                        <span style={{display: 'none'}}>
                          {track.position}
                        </span>
                        {track.number}
                      </td>
                      <td>
                        {track.recording ? (
                          <EntityLink
                            content={track.name}
                            entity={track.recording}
                          />
                        ) : (
                          <DeletedLink
                            allowNew={false}
                            name={track.name}
                          />
                        )}
                      </td>
                      <td>
                        <ArtistCreditLink
                          artistCredit={track.artistCredit}
                        />
                      </td>
                      <td className="treleases">
                        {formatTrackLength(track.length)}
                      </td>
                    </tr>
                  )) : null}
                </React.Fragment>
              );
            })}
          </tbody>
        </table>
      </div>

      <div
        id="merge-strategy-2"
        style={mergeStrategy.value === 2 ? null : {display: 'none'}}
      >
        <p>
          {l(`This merge strategy will merge all mediums together
              into a single set of mediums. Recordings between mediums
              will also be merged, into the recordings used
              on the target mediums.`)}
        </p>
        <p>
          {l(`This requires that corresponding mediums have
              the same number of tracks.`)}
        </p>
        <p>
          {l(`Make sure all mediums in the releases being merged
              are in the correct position. For example, to merge a medium
              into medium 2 of a release, it will need to be set
              as medium 2 of the release being merged.`)}
        </p>

        {badRecordingMerges?.length ? (
          <>
            <Warning
              message={l(
                `The recording artists do not match! Perhaps you meant
                to use the "append mediums" merge strategy?`,
              )}
            />
            <p>
              {l(`The recordings that will be merged if you continue
                  with the current merge strategy include the following,
                  whose artists differ:`)}
            </p>
            {badRecordingMerges.map((badRecordingsGroup, index) => (
              <ul key={index}>
                {badRecordingsGroup.map(badRecording => (
                  <li key={badRecording.id}>
                    <DescriptiveLink entity={badRecording} />
                    <br />
                    <ExpandedArtistCreditList
                      artistCredit={badRecording.artistCredit}
                    />
                  </li>
                ))}
              </ul>
            ))}
          </>
        ) : null}
      </div>
    </>
  );
};

export default (hydrate<Props>(
  'div.release-merge-strategy',
  ReleaseMergeStrategy,
): React.AbstractComponent<Props, void>);
