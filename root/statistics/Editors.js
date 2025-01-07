/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import {l as lMbServer} from '../static/scripts/common/i18n.js';
import loopParity from '../utility/loopParity.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount} from './utilities.js';

type EditorStatT = {
  +count: number,
  +editor: EditorT,
};

component EditorStatsTable(
  countLabel: string,
  dataPoints: $ReadOnlyArray<EditorStatT>,
  editorLabel: string,
  tableLabel: string,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <h3>{tableLabel}</h3>
      <table className="tbl">
        <thead>
          <tr>
            <th className="pos">{l_statistics('Rank')}</th>
            <th>
              {editorLabel}
              <div className="arrow" />
            </th>
            <th>
              {countLabel}
              <div className="arrow" />
            </th>
          </tr>
        </thead>
        <tbody>
          {dataPoints.length > 0 ? (
            dataPoints.map((editorStat, index) => (
              <tr
                className={loopParity(index)}
                key={
                  editorStat.editor
                    ? editorStat.editor.id
                    : `missing-${index}`
                }
              >
                <td className="t">{index + 1}</td>
                <td><EditorLink editor={editorStat.editor} /></td>
                <td className="t">{formatCount($c, editorStat.count)}</td>
              </tr>
            ))
          ) : (
            <tr className="even">
              <td colSpan="3">
                {l_statistics('There is no data to display here.')}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </>
  );
}

component Editors(
  dateCollected: string,
  topEditors: $ReadOnlyArray<EditorStatT>,
  topRecentlyActiveEditors: $ReadOnlyArray<EditorStatT>,
  topRecentlyActiveVoters: $ReadOnlyArray<EditorStatT>,
  topVoters: $ReadOnlyArray<EditorStatT>,
) {
  return (
    <StatisticsLayout
      fullWidth
      page="editors"
      title={lMbServer('Editors')}
    >
      <p>
        {texp.l_statistics('Last updated: {date}', {date: dateCollected})}
      </p>
      <p>
        {l_statistics(`For the vote statistics, only yes or no votes are
                       counted, abstain votes are not counted.`)}
      </p>
      <div
        style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
      >
        <h2 style={{marginTop: 0}}>{l_statistics('Editors')}</h2>
        <EditorStatsTable
          countLabel={l_statistics('Open and applied edits in past week')}
          dataPoints={topRecentlyActiveEditors}
          editorLabel={lMbServer('Editor')}
          tableLabel={l_statistics('Most active editors in the past week')}
        />
        <EditorStatsTable
          countLabel={l_statistics('Total applied edits')}
          dataPoints={topEditors}
          editorLabel={lMbServer('Editor')}
          tableLabel={l_statistics('Top editors overall')}
        />
      </div>
      <div
        style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
      >
        <h2 style={{marginTop: 0}}>{l_statistics('Voters')}</h2>
        <EditorStatsTable
          countLabel={l_statistics('Votes in past week')}
          dataPoints={topRecentlyActiveVoters}
          editorLabel={l_statistics('Voter')}
          tableLabel={l_statistics('Most active voters in the past week')}
        />
        <EditorStatsTable
          countLabel={l_statistics('Total votes')}
          dataPoints={topVoters}
          editorLabel={l_statistics('Voter')}
          tableLabel={l_statistics('Top voters overall')}
        />
      </div>
    </StatisticsLayout>
  );
}

export default Editors;
