/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LinkSearchableEditType from '../components/LinkSearchableEditType.js';
import {CatalystContext} from '../context.mjs';
import {l as lMbServer} from '../static/scripts/common/i18n.js';
import {l_statistics as l} from '../static/scripts/common/i18n/statistics.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, formatPercentage, TimelineLink} from './utilities.js';

type EditCategoryT = {
  +edit_name: string,
  +edit_type: string,
};

type EditsStatsT = {
  +dateCollected: string,
  +stats: {[statName: string]: number},
  +statsByCategory: {[editCategory: string]: $ReadOnlyArray<EditCategoryT>},
};

const Edits = ({
  dateCollected,
  stats,
  statsByCategory,
}: EditsStatsT): React.Element<typeof StatisticsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <StatisticsLayout fullWidth page="edits" title={l('Edits')}>
      <p>
        {texp.l('Last updated: {date}', {date: dateCollected})}
      </p>
      <h2>{l('Edits')}</h2>
      {Object.keys(statsByCategory).length === 0 ? (
        <p>
          {l('No edit statistics available.')}
        </p>
      ) : (
        <table className="database-statistics">
          <tbody>
            <tr>
              <th colSpan="2">{addColonText(l('Edits'))}</th>
              <td>
                {formatCount($c, stats['count.edit'])}
                {' '}
                <TimelineLink statName="count.edit" />
              </td>

              <td />
            </tr>
            {Object.keys(statsByCategory)
              .sort()
              .map((categoryKey) => {
                const category = statsByCategory[categoryKey];
                return (
                  <>
                    <tr className="thead">
                      <th colSpan="4">{categoryKey}</th>
                    </tr>
                    {category.map((type) => (
                      <tr key={type.edit_type}>
                        <th />
                        <th>{lMbServer(type.edit_name)}</th>
                        <td>
                          <LinkSearchableEditType
                            editTypeId={type.edit_type}
                            text={formatCount(
                              $c,
                              stats['count.edit.type.' + type.edit_type],
                            )}
                          />
                          {' '}
                          <TimelineLink
                            statName={'count.edit.type.' + type.edit_type}
                          />
                        </td>
                        <td>
                          {formatPercentage(
                            $c,
                            stats['count.edit.type.' + type.edit_type] /
                              stats['count.edit'],
                            2,
                          )}
                        </td>
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
};

export default Edits;
