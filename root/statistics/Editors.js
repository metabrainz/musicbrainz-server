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
import {l_statistics as l} from '../static/scripts/common/i18n/statistics.js';
import loopParity from '../utility/loopParity.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount} from './utilities.js';

type EditorsStatsT = {
  +dateCollected: string,
  +topEditors: $ReadOnlyArray<EditorStatT>,
  +topRecentlyActiveEditors: $ReadOnlyArray<EditorStatT>,
  +topRecentlyActiveVoters: $ReadOnlyArray<EditorStatT>,
  +topVoters: $ReadOnlyArray<EditorStatT>,
};

type EditorStatsTableProps = {
  countLabel: string,
  dataPoints: $ReadOnlyArray<EditorStatT>,
  editorLabel: string,
  tableLabel: string,
};

type EditorStatT = {
  +count: number,
  +editor: EditorT,
};

const EditorStatsTable = ({
  countLabel,
  dataPoints,
  editorLabel,
  tableLabel,
}: EditorStatsTableProps) => {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <h3>{tableLabel}</h3>
      <table className="tbl">
        <thead>
          <tr>
            <th className="pos">{l('Rank')}</th>
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
              <td colSpan="3">{l('There is no data to display here.')}</td>
            </tr>
          )}
        </tbody>
      </table>
    </>
  );
};

const Editors = ({
  dateCollected,
  topEditors,
  topRecentlyActiveEditors,
  topRecentlyActiveVoters,
  topVoters,
}: EditorsStatsT): React$Element<typeof StatisticsLayout> => (
  <StatisticsLayout fullWidth page="editors" title={l('Editors')}>
    <p>
      {texp.l('Last updated: {date}', {date: dateCollected})}
    </p>
    <p>
      {l(`For the vote statistics, only yes or no votes are counted, abstain
          votes are not counted.`)}
    </p>
    <div
      style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
    >
      <h2 style={{marginTop: 0}}>{l('Editors')}</h2>
      <EditorStatsTable
        countLabel={l('Open and applied edits in past week')}
        dataPoints={topRecentlyActiveEditors}
        editorLabel={l('Editor')}
        tableLabel={l('Most active editors in the past week')}
      />
      <EditorStatsTable
        countLabel={l('Total applied edits')}
        dataPoints={topEditors}
        editorLabel={l('Editor')}
        tableLabel={l('Top editors overall')}
      />
    </div>
    <div
      style={{display: 'inline-block', float: 'left', marginRight: '50px'}}
    >
      <h2 style={{marginTop: 0}}>{l('Voters')}</h2>
      <EditorStatsTable
        countLabel={l('Votes in past week')}
        dataPoints={topRecentlyActiveVoters}
        editorLabel={l('Voter')}
        tableLabel={l('Most active voters in the past week')}
      />
      <EditorStatsTable
        countLabel={l('Total votes')}
        dataPoints={topVoters}
        editorLabel={l('Voter')}
        tableLabel={l('Top voters overall')}
      />
    </div>
  </StatisticsLayout>
);

export default Editors;
