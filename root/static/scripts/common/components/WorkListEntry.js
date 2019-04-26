/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import loopParity from '../../../../utility/loopParity';

import ArtistCreditLink from './ArtistCreditLink';
import ArtistRoles from './ArtistRoles';
import CodeLink from './CodeLink';
import EntityLink from './EntityLink';

type WorkListRowProps = {|
  +hasIswcColumn: boolean,
  +hasMergeColumn: boolean,
  +work: WorkT,
|};

type WorkListEntryProps = {|
  +hasIswcColumn: boolean,
  +hasMergeColumn: boolean,
  +index: number,
  +score?: number,
  +work: WorkT,
|};

export const WorkListRow = ({
  hasIswcColumn,
  hasMergeColumn,
  work,
}: WorkListRowProps) => (
  <>
    {hasMergeColumn ? (
      <td>
        <input
          name="add-to-merge"
          type="checkbox"
          value={work.id}
        />
      </td>
    ) : null}
    <td><EntityLink entity={work} /></td>
    <td>
      <ArtistRoles relations={work.writers} />
    </td>
    <td>
      <ul>
        {work.artists.map((artist, i) => (
          <li key={i}>
            <ArtistCreditLink artistCredit={artist} />
          </li>
        ))}
      </ul>
    </td>
    {hasIswcColumn ? (
      <td>
        <ul>
          {work.iswcs.map((iswc, i) => (
            <li key={i}>
              <CodeLink code={iswc} />
            </li>
          ))}
        </ul>
      </td>
    ) : null}
    <td>{work.typeName ? lp_attributes(work.typeName, 'work_type') : null}</td>
    <td>
      <ul>
        {work.languages.map(language => (
          <li key={language.language.id}>
            <abbr title={l_languages(language.language.name)}>
              {language.language.iso_code_3}
            </abbr>
          </li>
        ))}
      </ul>
    </td>
  </>
);

const WorkListEntry = ({
  hasIswcColumn,
  hasMergeColumn,
  index,
  score,
  work,
}: WorkListEntryProps) => (
  <tr className={loopParity(index)} data-score={score ? score : null}>
    <WorkListRow
      hasIswcColumn={hasIswcColumn}
      hasMergeColumn={hasMergeColumn}
      work={work}
    />
  </tr>
);

export default WorkListEntry;
