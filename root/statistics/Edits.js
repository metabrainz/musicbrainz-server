/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';
import {l_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';
import manifest from '../static/manifest';

import {formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';
import type {EditsStatsT} from './types';

const Edits = ({$c, dateCollected, stats, statsByCategory}: EditsStatsT) => (
  <StatisticsLayout fullWidth page="edits" title={l_statistics('Edits')}>
    {manifest.css('statistics')}
    <p>{l_statistics('Last updated: {date}',
      {__react: true, date: stats.date_collected})}
    </p>
    <h2>{l_statistics('Edits')}</h2>
    {statsByCategory.length === 0 ? (
      <p>
        {l_statistics('No edit statistics available.')}
      </p>
    ) : (
      <table className="database-statistics">
        <tbody>
          <tr>
            <th colSpan="2">{l_statistics('Edits:')}</th>
            <td>{formatCount(stats.data['count.edit'], $c)}</td>
            <td />
          </tr>
          {Object.keys(statsByCategory).sort().map((categoryKey) => {
            const category = statsByCategory[categoryKey];
            return (
              <>
                <tr className="thead">
                  <th colSpan="4">{categoryKey}</th>
                </tr>
                {category.map((type) => (
                  <tr key={type.edit_type}>
                    <th />
                    <th>{l(type.edit_name)}</th>
                    <td>{formatCount(stats.data['count.edit.type.' + type.edit_type], $c)}</td>
                    <td>{formatPercentage(stats.data['count.edit.type.' + type.edit_type] / stats.data['count.edit'], 2, $c)}</td>
                  </tr>
                ))}
              </>
            );
          })}
        </tbody>
      </table>
    )}
  </StatisticsLayout>
);

export default withCatalystContext(Edits);
