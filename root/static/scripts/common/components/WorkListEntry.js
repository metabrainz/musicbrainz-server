/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../../context';
import RatingStars from '../../../../components/RatingStars';
import loopParity from '../../../../utility/loopParity';

import ArtistCreditLink from './ArtistCreditLink';
import ArtistRoles from './ArtistRoles';
import CodeLink from './CodeLink';
import AttributeList from './AttributeList';
import EntityLink from './EntityLink';

type WorkListRowProps = {|
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +showAttributes?: boolean,
  +showIswcs?: boolean,
  +showRatings?: boolean,
  +work: WorkT,
|};

type WorkListEntryProps = {|
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +index: number,
  +score?: number,
  +showAttributes?: boolean,
  +showIswcs?: boolean,
  +showRatings?: boolean,
  +work: WorkT,
|};

export const WorkListRow = withCatalystContext<WorkListRowProps>(({
  $c,
  checkboxes,
  seriesItemNumbers,
  showAttributes,
  showIswcs,
  showRatings,
  work,
}: WorkListRowProps) => (
  <>
    {$c.user_exists && checkboxes ? (
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
    {showAttributes ? (
      <td>
        <AttributeList entity={work} />
      </td>
    ) : null}
    {showRatings ? (
      <td>
        <RatingStars entity={work} />
      </td>
    ) : null}
  </>
));

const WorkListEntry = ({
  checkboxes,
  index,
  score,
  seriesItemNumbers,
  showAttributes,
  showIswcs,
  showRatings,
  work,
}: WorkListEntryProps) => (
  <tr className={loopParity(index)} data-score={score || null}>
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
