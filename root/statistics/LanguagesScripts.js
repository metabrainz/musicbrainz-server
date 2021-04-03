/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import manifest from '../static/manifest';
import {l_statistics as l} from '../static/scripts/common/i18n/statistics';
import loopParity from '../utility/loopParity';
import LinkSearchableProperty from '../components/LinkSearchableProperty';

import {formatCount, TimelineLink} from './utilities';
import StatisticsLayout from './StatisticsLayout';

type LanguagesScriptsStatsT = {
  +$c: CatalystContextT,
  +dateCollected: string,
  +languageStats: $ReadOnlyArray<LanguageStatT>,
  +scriptStats: $ReadOnlyArray<ScriptStatT>,
};

type LanguageStatT = {
  +entity: LanguageT | null,
  +releases: number,
  +total: number,
  +works: number,
};

type ScriptStatT = {
  +count: number,
  +entity: ScriptT | null,
};

const LanguagesScripts = ({
  $c,
  dateCollected,
  languageStats,
  scriptStats,
}: LanguagesScriptsStatsT): React.Element<typeof StatisticsLayout> => (
  <StatisticsLayout
    fullWidth
    page="languages-scripts"
    title={l('Languages and Scripts')}
  >
    <p>
      {texp.l('Last updated: {date}', {date: dateCollected})}
    </p>
    <p>
      {l(`All other available languages and scripts
          have 0 releases and works.`)}
    </p>
    <div
      style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
    >
      <h2 style={{marginTop: 0}}>{l('Languages')}</h2>
      <table className="tbl" id="languages-table">
        <thead>
          <tr>
            <th className="pos">{l('Rank')}</th>
            <th>
              {l('Languages')}
              <div className="arrow" />
            </th>
            <th>
              {l('Releases')}
              <div className="arrow" />
            </th>
            <th>
              {l('Works')}
              <div className="arrow" />
            </th>
            <th>
              {l('Total')}
              <div className="arrow" />
            </th>
          </tr>
        </thead>
        <tbody>
          {languageStats.map((languageStat, index) => (
            languageStat.total > 0 ? (
              <tr className={loopParity(index)} key={'language' + index}>
                <td className="t">{index + 1}</td>
                <td>
                  {languageStat.entity
                    ? l_languages(languageStat.entity.name)
                    : l('Unknown language')}
                </td>
                <td className="t">
                  {languageStat.entity && languageStat.entity.iso_code_3 ? (
                    <LinkSearchableProperty
                      entityType="release"
                      searchField="lang"
                      searchValue={languageStat.entity.iso_code_3}
                      text={formatCount($c, languageStat.releases)}
                    />
                  ) : (
                    formatCount($c, languageStat.releases)
                  )}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.release.language.' + (
                        languageStat.entity?.iso_code_3 ?? 'null'
                      )
                    }
                  />
                </td>
                <td className="t">
                  {languageStat.entity && languageStat.entity.iso_code_3 ? (
                    <LinkSearchableProperty
                      entityType="work"
                      searchField="lang"
                      searchValue={languageStat.entity.iso_code_3}
                      text={formatCount($c, languageStat.works)}
                    />
                  ) : (
                    formatCount($c, languageStat.works)
                  )}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.work.language.' + (
                        languageStat.entity?.iso_code_3 ?? 'null'
                      )
                    }
                  />
                </td>
                <td className="t">{formatCount($c, languageStat.total)}</td>
              </tr>
            ) : null
          ))}
        </tbody>
      </table>
    </div>
    <div style={{display: 'inline-block', float: 'left'}}>
      <h2 style={{marginTop: 0}}>{l('Scripts')}</h2>
      <table className="tbl" id="scripts-table">
        <thead>
          <tr>
            <th className="pos">{l('Rank')}</th>
            <th>
              {l('Script')}
              <div className="arrow" />
            </th>
            <th>
              {l('Releases')}
              <div className="arrow" />
            </th>
          </tr>
        </thead>
        <tbody>
          {scriptStats.map((scriptStat, index) => (
            scriptStat.count > 0 ? (
              <tr className={loopParity(index)} key={'script' + index}>
                <td className="t">{index + 1}</td>
                <td>
                  {scriptStat.entity
                    ? l_scripts(scriptStat.entity.name)
                    : l('Unknown script')}
                </td>
                <td className="t">
                  {scriptStat.entity ? (
                    <LinkSearchableProperty
                      entityType="release"
                      searchField="script"
                      searchValue={scriptStat.entity.iso_code}
                      text={formatCount($c, scriptStat.count)}
                    />
                  ) : (
                    formatCount($c, scriptStat.count)
                  )}
                  {' '}
                  <TimelineLink
                    statName={
                      'count.release.script.' + (
                        scriptStat.entity?.iso_code ?? 'null'
                      )
                    }
                  />
                </td>
              </tr>
            ) : null
          ))}
        </tbody>
      </table>
    </div>
    {manifest.js('statistics')}
  </StatisticsLayout>
);

export default LanguagesScripts;
