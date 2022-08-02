/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import localizeLanguageName from '../i18n/localizeLanguageName';
import {CatalystContext} from '../../../../context.mjs';
import * as manifest from '../../../manifest.mjs';
import RatingStars from '../../../../components/RatingStars';
import loopParity from '../../../../utility/loopParity';

import ArtistRoles from './ArtistRoles';
import AttributeList from './AttributeList';
import CodeLink from './CodeLink';
import EntityLink from './EntityLink';
import WorkArtists from './WorkArtists';

type WorkListRowProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +showAttributes?: boolean,
  +showIswcs?: boolean,
  +showRatings?: boolean,
  +work: WorkT,
};

type WorkListEntryProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +index: number,
  +score?: number,
  +showAttributes?: boolean,
  +showIswcs?: boolean,
  +showRatings?: boolean,
  +work: WorkT,
};

export const WorkListRow = ({
  checkboxes,
  seriesItemNumbers,
  showAttributes = false,
  showIswcs = false,
  showRatings = false,
  work,
}: WorkListRowProps): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);

  return (
    <>
      {$c.user && nonEmpty(checkboxes) ? (
        <td>
          <input
            name={checkboxes}
            type="checkbox"
            value={work.id}
          />
        </td>
      ) : null}
      {seriesItemNumbers ? (
        <td style={{width: '1em'}}>
          {seriesItemNumbers[work.id]}
        </td>
      ) : null}
      <td><EntityLink entity={work} /></td>
      <td>
        <ArtistRoles relations={work.writers} />
        {manifest.js(
          'common/components/ArtistRoles',
          {async: 'async'},
        )}
      </td>
      <td>
        <WorkArtists artists={work.artists} />
        {manifest.js(
          'common/components/WorkArtists',
          {async: 'async'},
        )}
      </td>
      {showIswcs ? (
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
      <td>
        {nonEmpty(work.typeName)
          ? lp_attributes(work.typeName, 'work_type')
          : null}
      </td>
      <td>
        <ul>
          {work.languages.map(language => (
            <li
              data-iso-639-3={language.language.iso_code_3}
              key={language.language.id}
            >
              {localizeLanguageName(language.language, true)}
            </li>
          ))}
        </ul>
      </td>
      {showAttributes ? (
        <td>
          {work.attributes ? (
            <ul>
              <AttributeList attributes={work.attributes} />
              {manifest.js(
                'common/components/AttributeList',
                {async: 'async'},
              )}
            </ul>
          ) : null}
        </td>
      ) : null}
      {showRatings ? (
        <td>
          <RatingStars entity={work} />
        </td>
      ) : null}
    </>
  );
};

const WorkListEntry = ({
  checkboxes,
  index,
  score,
  seriesItemNumbers,
  showAttributes,
  showIswcs,
  showRatings,
  work,
}: WorkListEntryProps): React.Element<'tr'> => (
  <tr className={loopParity(index)} data-score={score ?? null}>
    <WorkListRow
      checkboxes={checkboxes}
      seriesItemNumbers={seriesItemNumbers}
      showAttributes={showAttributes}
      showIswcs={showIswcs}
      showRatings={showRatings}
      work={work}
    />
  </tr>
);

export default WorkListEntry;
