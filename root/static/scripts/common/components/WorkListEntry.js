/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity.js';
import manifest from '../../../manifest.mjs';
import localizeLanguageName from '../i18n/localizeLanguageName.js';

import ArtistRoles from './ArtistRoles.js';
import AttributeList from './AttributeList.js';
import EntityLink from './EntityLink.js';
import IswcList from './IswcList.js';
import RatingStars from './RatingStars.js';
import WorkArtists from './WorkArtists.js';

export component WorkListRow(
  checkboxes?: string,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showAttributes: boolean = false,
  showIswcs: boolean = false,
  showRatings: boolean = false,
  work: WorkT,
) {
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
        {manifest('common/components/ArtistRoles', {async: 'async'})}
      </td>
      <td>
        <WorkArtists artists={work.artists} />
        {manifest('common/components/WorkArtists', {async: 'async'})}
      </td>
      <td>
        <ArtistRoles relations={work.misc_artists} />
      </td>
      {showIswcs ? (
        <td>
          <IswcList iswcs={work.iswcs} />
          {manifest('common/components/ArtistRoles', {async: 'async'})}
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
            <>
              <AttributeList attributes={work.attributes} />
              {manifest('common/components/AttributeList', {async: 'async'})}
            </>
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
}

component WorkListEntry(
  index: number,
  score?: number,
  ...rowProps: React.PropsOf<WorkListRow>
) {
  return (
    <tr className={loopParity(index)} data-score={score ?? null}>
      <WorkListRow {...rowProps} />
    </tr>
  );
}

export default WorkListEntry;
