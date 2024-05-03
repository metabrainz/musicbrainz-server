/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LinkSearchableProperty from '../components/LinkSearchableProperty.js';
import {CatalystContext} from '../context.mjs';
import * as manifest from '../static/manifest.mjs';
import loopParity from '../utility/loopParity.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, TimelineLink} from './utilities.js';

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

component LanguagesScripts(
  dateCollected: string,
  languageStats: $ReadOnlyArray<LanguageStatT>,
  scriptStats: $ReadOnlyArray<ScriptStatT>,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout
      fullWidth
      page="languages-scripts"
      title={l_statistics('Languages and scripts')}
    >
      <p>
        {texp.l_statistics('Last updated: {date}', {date: dateCollected})}
      </p>
      <p>
        {l_statistics(`All other available languages and scripts
            have 0 releases and works.`)}
      </p>
      <div
        style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
      >
        <h2 style={{marginTop: 0}}>{l_statistics('Languages')}</h2>
        <table className="tbl" id="languages-table">
          <thead>
            <tr>
              <th className="pos">{l_statistics('Rank')}</th>
              <th>
                {l_statistics('Languages')}
                <div className="arrow" />
              </th>
              <th>
                {l_statistics('Releases')}
                <div className="arrow" />
              </th>
              <th>
                {l_statistics('Works')}
                <div className="arrow" />
              </th>
              <th>
                {l_statistics('Total')}
                <div className="arrow" />
              </th>
            </tr>
          </thead>
          <tbody>
            {languageStats.map((languageStat, index) => {
              const language = languageStat.entity;
              const isoCode3 = language?.iso_code_3;

              return (
                languageStat.total > 0 ? (
                  <tr className={loopParity(index)} key={'language' + index}>
                    <td className="t">{index + 1}</td>
                    <td>
                      {language
                        ? l_languages(language.name)
                        : l_statistics('Unknown language')}
                    </td>
                    <td className="t">
                      {nonEmpty(isoCode3) ? (
                        <LinkSearchableProperty
                          entityType="release"
                          searchField="lang"
                          searchValue={isoCode3}
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
                      {nonEmpty(isoCode3) ? (
                        <LinkSearchableProperty
                          entityType="work"
                          searchField="lang"
                          searchValue={isoCode3}
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
                    <td className="t">
                      {formatCount($c, languageStat.total)}
                    </td>
                  </tr>
                ) : null
              );
            })}
          </tbody>
        </table>
      </div>
      <div style={{display: 'inline-block', float: 'left'}}>
        <h2 style={{marginTop: 0}}>{l_statistics('Scripts')}</h2>
        <table className="tbl" id="scripts-table">
          <thead>
            <tr>
              <th className="pos">{l_statistics('Rank')}</th>
              <th>
                {l_statistics('Script')}
                <div className="arrow" />
              </th>
              <th>
                {l_statistics('Releases')}
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
                      : l_statistics('Unknown script')}
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
}

export default LanguagesScripts;
