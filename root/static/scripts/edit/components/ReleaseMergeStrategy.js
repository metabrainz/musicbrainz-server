/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import loopParity from '../../../../utility/loopParity.js';
import ArtistCreditLink
  from '../../common/components/ArtistCreditLink.js';
import DescriptiveLink
  from '../../common/components/DescriptiveLink.js';
import EntityLink, {DeletedLink}
  from '../../common/components/EntityLink.js';
import {ExpandedArtistCreditList}
  from '../../common/components/ExpandedArtistCredit.js';
import Warning from '../../common/components/Warning.js';
import formatTrackLength
  from '../../common/utility/formatTrackLength.js';
import {createCompoundFieldFromObject} from '../utility/createField.js';
import isUselessMediumTitle from '../utility/isUselessMediumTitle.js';

import FormRowSelect from './FormRowSelect.js';

const mergeStrategyOptions = {
  grouped: false as const,
  options: [
    {label: N_l('Append mediums to target release'), value: 1},
    {label: N_l('Merge mediums and recordings'), value: 2},
  ],
};

component UselessMediumTitleWarning(name: string) {
  return (
    <tr>
      <td colSpan={4}>
        <span
          className="error"
          style={{margin: '0 12px 0 6px'}}
        >
          {exp.l(
            `“{matched_text}” seems to indicate medium ordering rather than
             a medium title. If this is the case, please set the appropriate
             medium position instead of adding a title
             (see {release_style|the guidelines}).`,
            {
              matched_text: name,
              release_style: '/doc/Style/Release#Medium_title',
            },
          )}
        </span>
      </td>
    </tr>
  );
}

component ReleaseMergeStrategy(
  badRecordingMerges?:
    $ReadOnlyArray<$ReadOnlyArray<RecordingT>>,
  form: MergeReleasesFormT,
  mediums: $ReadOnlyArray<MediumT>,
  releases: {+[releaseID: number]: ReleaseT},
) {
  const [mergeStrategy, setMergeStrategy] =
    React.useState(form.field.merge_strategy);

  function updateStrategy(event: SyntheticEvent<HTMLSelectElement>) {
    setMergeStrategy({
      ...mergeStrategy,
      value: event.currentTarget.value,
    });
  }

  const mediumsMap = form.field.medium_positions.field.map;

  const [mediumTitles, setMediumTitles] =
    React.useState(mediumsMap.field.map(
      (field, index) => (field?.field.name.value) ?? (mediums[index]?.name),
    ));

  function updateTitles(
    event: SyntheticEvent<HTMLInputElement>,
    index: number,
  ) {
    const mediumTitle = event.currentTarget.value;
    setMediumTitles(prevTitles => {
      const titles = [...prevTitles];
      titles[index] = mediumTitle;
      return titles;
    });
  }

  return (
    <>
      <FormRowSelect
        field={mergeStrategy}
        hasHtmlErrors
        label={l('Merge strategy:')}
        onChange={updateStrategy}
        options={mergeStrategyOptions}
      />

      <div
        id="merge-strategy-1"
        style={String(mergeStrategy.value) === '1' ? null : {display: 'none'}}
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
              let mediumField = mediumsMap.field[index];
              if (!mediumField) {
                mediumField = createCompoundFieldFromObject(
                  mediumsMap.html_name + '.' + String(index),
                  {
                    id: medium.id,
                    name: medium.name,
                    position: medium.position,
                    release_id: medium.release_id,
                  },
                );
              }
              const mediumSubFields = mediumField.field;

              return (
                <React.Fragment key={medium.id}>
                  <tr className="subh">
                    <th colSpan={4}>
                      <label>{l('New position:')}</label>
                      {' '}
                      <input
                        defaultValue={mediumSubFields.position.value}
                        name={mediumSubFields.position.html_name}
                        size={2}
                        type="text"
                      />
                      {mediumSubFields.position.has_errors ? (
                        <span
                          className="error"
                          style={{margin: '0 12px 0 6px'}}
                        >
                          {mediumSubFields.position.errors[0]}
                        </span>
                      ) : null}
                      {' '}
                      <label>{l('New disc title:')}</label>
                      {' '}
                      <input
                        defaultValue={mediumSubFields.name.value}
                        name={mediumSubFields.name.html_name}
                        onChange={event => updateTitles(event, index)}
                        type="text"
                      />
                      <input
                        name={mediumSubFields.id.html_name}
                        type="hidden"
                        value={mediumSubFields.id.value}
                      />
                      <input
                        name={mediumSubFields.release_id.html_name}
                        type="hidden"
                        value={mediumSubFields.release_id.value}
                      />
                      {' '}
                      {medium.name ? (
                        exp.l(
                          `(was medium {position}: {name}
                          on release {release})`,
                          {
                            name: medium.name,
                            position: medium.position,
                            release: (
                              <EntityLink
                                entity={releases[medium.release_id]}
                              />
                            ),
                          },
                        )
                      ) : (
                        exp.l(
                          '(was medium {position} on release {release})',
                          {
                            position: medium.position,
                            release: (
                              <EntityLink
                                entity={releases[medium.release_id]}
                              />
                            ),
                          },
                        )
                      )}
                    </th>
                  </tr>
                  {isUselessMediumTitle(mediumTitles[index]) ? (
                    <UselessMediumTitleWarning
                      name={mediumTitles[index]}
                    />
                  ) : null}
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
        style={String(mergeStrategy.value) === '2' ? null : {display: 'none'}}
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
}

export default (hydrate<React.PropsOf<ReleaseMergeStrategy>>(
  'div.release-merge-strategy',
  ReleaseMergeStrategy,
): component(...React.PropsOf<ReleaseMergeStrategy>));
