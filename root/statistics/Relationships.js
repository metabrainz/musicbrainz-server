/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';
import manifest from '../static/manifest';
import formatEntityTypeName from '../static/scripts/common/utility/formatEntityTypeName';

import {formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';
import type {RelationshipsStatsT} from './types';

const TypeRows = withCatalystContext(({$c, base, indent, parent, stats, type}) => {
  return (
    <>
      <tr>
        <th style={{paddingLeft: (indent - 1) + 'em'}}>{l_statistics(type.long_link_phrase)}</th>
        <td>{formatCount(stats.data[base + '.' + type.name], $c)}</td>
        <td>{formatCount(stats.data[base + '.' + type.name + '.inclusive'], $c)}</td>
        <td>{formatPercentage(stats.data[base + '.' + type.name + '.inclusive'] / stats.data[parent], 1, $c)}</td>
      </tr>
      {type.children ? (
        type.children.sort((a, b) => a.long_link_phrase.localeCompare(b.long_link_phrase)).map((child) => (
          <TypeRows base={base} indent={indent + 1} key={child.id} parent={base + '.' + type.name + '.inclusive'} stats={stats} type={child} />
        ))
      ) : null}
    </>
  );
});

const Relationships = ({$c, dateCollected, stats, types}: RelationshipsStatsT) => (
  <StatisticsLayout fullWidth page="relationships" title={l_statistics('Relationships')}>
    {manifest.css('statistics')}
    <p>{l_statistics('Last updated: {date}',
      {__react: true, date: stats.date_collected})}
    </p>
    <h2>{l_statistics('Relationships')}</h2>
    {stats.data['count.ar.links'] < 1 ? (
      <p>
        {l_statistics('No relationship statistics available.')}
      </p>
    ) : (
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th />
            <th>{l_statistics('Exclusive')}</th>
            <th>{l_statistics('Inclusive')}</th>
            <th />
          </tr>
          <tr>
            <th>{l_statistics('Relationships:')}</th>
            <td />
            <td>{formatCount(stats.data['count.ar.links'], $c)}</td>
            <td />
          </tr>
          {Object.keys(types).sort().map((typeKey) => {
            const type = types[typeKey];
            const type0 = formatEntityTypeName(type.entity_types[0]);
            const type1 = formatEntityTypeName(type.entity_types[1]);
            return (
              <>
                <tr className="thead">
                  <th colSpan="4">{l_statistics('{type0}-{type1}', {__react: true, type0: type0, type1: type1})}</th>
                </tr>
                <tr>
                  <th colSpan="2">{l_statistics('{type0}-{type1} relationships:', {__react: true, type0: type0, type1: type1})}</th>
                  <td>{formatCount(stats.data['count.ar.links.' + typeKey], $c)}</td>
                  <td>{formatPercentage(stats.data['count.ar.links.' + typeKey] / stats.data['count.ar.links'], 1, $c)}</td>
                </tr>
                {Object.keys(type.tree).sort().map((child) => {
                  console.log(type.tree);
                  return (
                  type.tree[child].sort((a, b) => a.long_link_phrase.localeCompare(b.long_link_phrase)).map((child2) => (
                    <TypeRows base={'count.ar.links.' + typeKey} indent={2} key={child2.id} parent={'count.ar.links.' + typeKey} stats={stats} type={child2} />
                  ))
                );})}
              </>
            );
          })}
        </tbody>
      </table>
    )}
  </StatisticsLayout>
);

export default withCatalystContext(Relationships);
