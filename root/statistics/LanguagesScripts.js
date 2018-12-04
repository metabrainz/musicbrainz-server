/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import manifest from '../static/manifest';
import {l_languages} from '../static/scripts/common/i18n/languages';
import {l_scripts} from '../static/scripts/common/i18n/scripts';
import {l_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';
import LinkSearchableProperty from '../components/LinkSearchableProperty';

import {formatCount} from './utilities';
import StatisticsLayout from './StatisticsLayout';

type LanguagesScriptsStatsT = {|
  +$c: CatalystContextT,
  +dateCollected: string,
  +languageStats: $ReadOnlyArray<LanguageStatT>,
  +scriptStats: $ReadOnlyArray<ScriptStatT>,
|};

type LanguageStatT = {|
  +entity: LanguageT | null,
  +releases: number,
  +total: number,
  +works: number,
|};

type ScriptStatT = {|
  +count: number,
  +entity: ScriptT | null,
|};

const LanguagesScripts = ({$c, dateCollected, languageStats, scriptStats}: LanguagesScriptsStatsT) => (
  <StatisticsLayout fullWidth page="languages-scripts" title={l_statistics('Languages and Scripts')}>
    {manifest.css('statistics')}
    <p>{l_statistics('Last updated: {date}',
      {date: dateCollected})}
    </p>
    <p>{l_statistics('All other available languages and scripts have 0 releases and works.')}</p>
    <div style={{display: 'inline-block', float: 'left', marginRight: '50px'}}>
      <h2 style={{marginTop: 0}}>{l_statistics('Languages')}</h2>
      <table className="tbl" id="languages-table">
        <thead>
          <tr>
            <th className="pos">{l_statistics('Rank')}</th>
            <th>{l_statistics('Languages')}<div className="arrow" /></th>
            <th>{l_statistics('Releases')}<div className="arrow" /></th>
            <th>{l_statistics('Works')}<div className="arrow" /></th>
            <th>{l_statistics('Total')}<div className="arrow" /></th>
          </tr>
        </thead>
        <tbody>
          {languageStats.map((languageStat, index) => (
            <tr className={loopParity(index)} key={'language' + index}>
              <td className="t">{index + 1}</td>
              <td>{languageStat.entity ? l_languages(languageStat.entity.name) : l_statistics('Unknown language')}</td>
              <td className="t">
                {languageStat.entity && languageStat.entity.iso_code_3 ? (
                  <LinkSearchableProperty entityType="release" searchField="lang" searchValue={languageStat.entity.iso_code_3} text={formatCount(languageStat.releases, $c)} />
                ) : (
                  formatCount(languageStat.releases, $c)
                )}
              </td>
              <td className="t">
                {languageStat.entity && languageStat.entity.iso_code_3 ? (
                  <LinkSearchableProperty entityType="work" searchField="lang" searchValue={languageStat.entity.iso_code_3} text={formatCount(languageStat.works, $c)} />
                ) : (
                  formatCount(languageStat.releases, $c)
                )}
              </td>
              <td className="t">{formatCount(languageStat.total, $c)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
    <div style={{display: 'inline-block', float: 'left'}}>
      <h2 style={{marginTop: 0}}>{l_statistics('Scripts')}</h2>
      <table className="tbl" id="scripts-table">
        <thead>
          <tr>
            <th className="pos">{l_statistics('Rank')}</th>
            <th>{l_statistics('Script')}<div className="arrow" /></th>
            <th>{l_statistics('Releases')}<div className="arrow" /></th>
          </tr>
        </thead>
        <tbody>
          {scriptStats.map((scriptStat, index) => (
            <tr className={loopParity(index)} key={'script' + index}>
              <td className="t">{index + 1}</td>
              <td>{scriptStat.entity ? l_scripts(scriptStat.entity.name) : l_statistics('Unknown script')}</td>
              <td className="t">
                {scriptStat.entity ? (
                  <LinkSearchableProperty entityType="release" searchField="script" searchValue={scriptStat.entity.iso_code} text={formatCount(scriptStat.count, $c)} />
                ) : (
                  formatCount(scriptStat.count, $c)
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
    {manifest.js('statistics')}
  </StatisticsLayout>
);

export default withCatalystContext(LanguagesScripts);
