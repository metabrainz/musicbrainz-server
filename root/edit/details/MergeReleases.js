/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseLabelList from '../../components/ReleaseLabelList';
import ReleaseCatnoList from '../../components/ReleaseCatnoList';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import EntityLink
  from '../../static/scripts/common/components/EntityLink';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import formatTrackLength from
  '../../static/scripts/common/utility/formatTrackLength';
import loopParity from '../../utility/loopParity';
import expand2react from '../../static/scripts/common/i18n/expand2react';

type MergeReleasesEditT = {
  ...EditT,
  +display_data: {
    +cannot_merge_recordings_reason?: {
      +message: string,
      +vars: {+[var: string]: string, ...},
    },
    +changes: $ReadOnlyArray<{
      +mediums: $ReadOnlyArray<{
        +id: number,
        +new_name: string,
        +new_position: number,
        +old_name: string,
        +old_position: StrOrNum,
      }>,
      +release: ReleaseT,
    }>,
    +edit_version: 1 | 2 | 3,
    +empty_releases?: $ReadOnlyArray<ReleaseT>,
    +merge_strategy: 'append' | 'merge',
    +new: ReleaseT,
    +old: $ReadOnlyArray<ReleaseT>,
    +recording_merges?: $ReadOnlyArray<{
      +destination: RecordingT,
      +large_spread: boolean,
      +medium: string,
      +sources: $ReadOnlyArray<RecordingT>,
      +track: string,
    }>,
  },
};

type Props = {
  +edit: MergeReleasesEditT,
};

const strategyDescriptions = {
  append: N_l('Append mediums to target release'),
  merge: N_l('Merge mediums and recordings'),
};

function buildReleaseRow(release, index) {
  return (
    <tr key={index == null ? null : 'release-' + index}>
      {release.gid ? (
        <>
          <td>
            <EntityLink entity={release} />
          </td>
          <td>
            <ArtistCreditLink artistCredit={release.artistCredit} />
          </td>
          <td>
            {nonEmpty(release.combined_format_name)
              ? release.combined_format_name
              : l('[missing media]')}
          </td>
          <td>
            {nonEmpty(release.combined_track_count)
              ? release.combined_track_count
              : lp('-', 'missing data')}
          </td>
          <td>
            <ReleaseEvents events={release.events} />
          </td>
          <td>
            <ReleaseLabelList labels={release.labels} />
          </td>
          <td>
            <ReleaseCatnoList labels={release.labels} />
          </td>
          <td className="barcode-cell">
            {formatBarcode(release.barcode)}
          </td>
        </>
      ) : (
        <td colSpan="8">
          <EntityLink entity={release} />
        </td>
      )}
    </tr>
  );
}

function buildChangesRow(change, index, editVersion) {
  return (
    <React.Fragment key={'changes-' + index}>
      {buildReleaseRow(change.release)}
      {change.mediums.map((medium, innerIndex) => {
        const hasNames = nonEmpty(medium.old_name) ||
          nonEmpty(medium.new_name);
        const hasBothNames = nonEmpty(medium.old_name) &&
          nonEmpty(medium.new_name);

        return (
          <tr
            className={loopParity(innerIndex)}
            key={'changes-' + index + '-medium-' + innerIndex}
          >
            <td colSpan="9">
              {editVersion === 3 && hasNames ? (
                hasBothNames ? (
                  exp.l(
                    `Medium {position}: {name}
                    is now medium {new_position}: {new_name}`,
                    {
                      name: medium.old_name,
                      new_name: medium.new_name,
                      new_position: medium.new_position,
                      position: medium.old_position,
                    },
                  )
                ) : nonEmpty(medium.old_name) ? (
                  exp.l(
                    'Medium {position}: {name} is now medium {new_position}',
                    {
                      name: medium.old_name,
                      new_position: medium.new_position,
                      position: medium.old_position,
                    },
                  )
                ) : (
                  exp.l(
                    `Medium {position}
                    is now medium {new_position}: {new_name}`,
                    {
                      new_name: medium.new_name,
                      new_position: medium.new_position,
                      position: medium.old_position,
                    },
                  )
                )
              ) : (
                exp.l(
                  'Medium {position} is now medium {new_position}',
                  {
                    new_position: medium.new_position,
                    position: medium.old_position,
                  },
                )
              )}
            </td>
          </tr>
        );
      })}
    </React.Fragment>
  );
}

function buildRecordingMergeRow(merge, index) {
  const rowSpan = merge.sources.length;

  return (
    <React.Fragment key={'recording-merge-' + index}>
      <tr className={loopParity(index)}>
        <td rowSpan={rowSpan}>
          {merge.medium + '.' + merge.track}
        </td>
        <td>
          <DescriptiveLink entity={merge.sources[0]} />
        </td>
        <td className={merge.large_spread ? 'warn-lengths' : ''}>
          {formatTrackLength(merge.sources[0].length)}
        </td>
        <td rowSpan={rowSpan}>
          <DescriptiveLink entity={merge.destination} />
        </td>
        <td
          className={merge.large_spread ? 'warn-lengths' : ''}
          rowSpan={rowSpan}
        >
          {formatTrackLength(merge.destination.length)}
        </td>
      </tr>
      {merge.sources.map((source, innerIndex) => {
        if (innerIndex === 0) {
          return null;
        }
        return (
          <tr
            className={loopParity(index)}
            key={'recording-merge-source-' + innerIndex}
          >
            <td>
              <DescriptiveLink entity={source} />
            </td>
            <td className={merge.large_spread ? 'warn-lengths' : ''}>
              {formatTrackLength(source.length)}
            </td>
          </tr>
        );
      })}
    </React.Fragment>
  );
}

function getHtmlVars(vars) {
  if (!vars || Object.keys(vars).length === 0) {
    return vars;
  }

  const htmlArgs = {};

  for (const key of Object.keys(vars)) {
    htmlArgs[key] = expand2react(vars[key]);
  }

  return htmlArgs;
}

const MergeReleases = ({
  edit,
}: Props): React.Element<typeof React.Fragment> => {
  const display = edit.display_data;
  const emptyReleases = display.empty_releases;
  const changes = display.changes;
  const recordingMerges = display.recording_merges;
  const cannotMergeRecordingsMessage = display.cannot_merge_recordings_reason;

  return (
    <>
      <table className="tbl merge-releases">
        <thead>
          <tr>
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
            <th>{l('Format')}</th>
            <th>{l('Tracks')}</th>
            <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
            <th>{l('Label')}</th>
            <th>{l('Catalog#')}</th>
            <th>{l('Barcode')}</th>
          </tr>
        </thead>
        <tbody>
          {display.merge_strategy === 'append' ? (
            <>
              {emptyReleases ? (
                emptyReleases.map((release, index) => (
                  <React.Fragment key={'empty-release-' + index}>
                    {buildReleaseRow(release)}
                    <tr className={loopParity(index)}>
                      <td colSpan="9">
                        {l('This release has no media to merge.')}
                      </td>
                    </tr>
                  </React.Fragment>
                ))
              ) : null}

              {changes.map((change, index) => buildChangesRow(
                change,
                index,
                display.edit_version,
              ))}

              {display.edit_version === 1 ? (
                <>
                  {display.old.map(buildReleaseRow)}
                  <tr className="subh">
                    <th colSpan="9">{l('Into:')}</th>
                  </tr>
                  {buildReleaseRow(display.new)}
                </>
              ) : (
                <>
                  <tr className="subh">
                    <th colSpan="9">{l('Into:')}</th>
                  </tr>
                  {buildReleaseRow(display.new)}
                </>
              )}
            </>
          ) : display.merge_strategy === 'merge' ? (
            <>
              {display.old.map(buildReleaseRow)}
              <tr className="subh">
                <th colSpan="9">{l('Into:')}</th>
              </tr>
              {buildReleaseRow(display.new)}
            </>
          ) : null}
        </tbody>
      </table>

      {display.merge_strategy === 'merge' ? (
        recordingMerges?.length ? (
          <table className="tbl">
            <thead>
              <tr>
                <th colSpan="5">{l('Recording Merges')}</th>
              </tr>
              <tr>
                <th>{l('Track #')}</th>
                <th colSpan="2">{l('Recording')}</th>
                <th colSpan="2">{l('Into:')}</th>
              </tr>
            </thead>
            <tbody>
              {recordingMerges.map(buildRecordingMergeRow)}
            </tbody>
          </table>
        ) : !recordingMerges && !edit.is_open ? (
          <p>
            <strong>
              {l(`This edit does not store recording merge information
                  and is closed, so no recording merge information
                  can be shown.`)}
            </strong>
          </p>
        ) : cannotMergeRecordingsMessage ? (
          <p className="error merge-error">
            <strong>
              {exp.l(
                cannotMergeRecordingsMessage.message,
                getHtmlVars(cannotMergeRecordingsMessage.vars),
              )}
            </strong>
          </p>
        ) : (
          <p>
            <strong>
              {l('All recordings for these releases are already merged.')}
            </strong>
          </p>
        )
      ) : null}

      <table className="details">
        <tr>
          <th>{l('Merge strategy:')}</th>
          <td>{strategyDescriptions[display.merge_strategy]()}</td>
        </tr>

        {display.edit_version === 1 ? (
          <tr>
            <th>{addColonText(l('Note'))}</th>
            <td>
              {l(`The data in this edit originally came
                  from an older version of this edit,
                  and may not display correctly`)}
            </td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default MergeReleases;
