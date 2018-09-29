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
import {l_statistics, ln_statistics, lp_statistics} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';

import {addColon, formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';
import type {MainStatsT} from './types';

const Index = ({
  $c,
  areaTypes,
  dateCollected,
  eventTypes,
  instrumentTypes,
  labelTypes,
  packagings,
  placeTypes,
  primaryTypes,
  secondaryTypes,
  seriesTypes,
  stats,
  statuses,
  workAttributeTypes,
  workTypes,
}: MainStatsT) => {
  const oneToNine = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  console.log(packagings);

  return (
    <StatisticsLayout fullWidth page="index" title={l_statistics('Overview')}>
      {manifest.css('statistics')}
      <p>{l_statistics('Last updated: {date}',
        {__react: true, date: dateCollected})}
      </p>
      <h2>{l_statistics('Basic metadata')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Core Entities')}</th>
          </tr>
          <tr>
            <th>{l_statistics('Artists:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.artist'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Release Groups:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.releasegroup'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Releases:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.release'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Mediums:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.medium'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Recordings:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.recording'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Tracks:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.track'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Labels:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.label'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Works:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.work'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('URLs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.url'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Areas:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.area'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Places:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.place'], $c)}</td>
          </tr>
          <tr>
            <th>{lp_statistics('Series:', 'plural')}</th>
            <td colSpan="3">{formatCount(stats.data['count.series'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Instruments:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.instrument'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Events:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.event'], $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Other Entities')}</th>
          </tr>
          <tr>
            <th>{l_statistics('Editors (valid / deleted):')}</th>
            <td>{formatCount(stats.data['count.editor.valid'], $c)}</td>
            <td>{'/'}</td>
            <td>{formatCount(stats.data['count.editor.deleted'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Relationships:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.ar.links'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('CD Stubs (all time / current):')}</th>
            <td>{formatCount(stats.data['count.cdstub.submitted'], $c)}</td><td>{'/'}</td><td> {formatCount(stats.data['count.cdstub'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Tags (raw / aggregated):')}</th>
            <td>
              {formatCount(stats.data['count.tag.raw'], $c)}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount(stats.data['count.tag'], $c)}
            </td>
          </tr>
          <tr>
            <th>{l_statistics('Ratings (raw / aggregated):')}</th>
            <td>
              {formatCount(stats.data['count.rating.raw'], $c)}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount(stats.data['count.rating'], $c)}
            </td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Identifiers')}</th>
          </tr>
          <tr>
            <th>{l_statistics('MBIDs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.mbid'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('ISRCs (all / unique):')}</th>
            <td>{formatCount(stats.data['count.isrc.all'], $c)}</td><td>{'/'}</td><td>{formatCount(stats.data['count.isrc'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('ISWCs (all / unique):')}</th>
            <td>{formatCount(stats.data['count.iswc.all'], $c)}</td><td>{'/'}</td><td>{formatCount(stats.data['count.iswc'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Disc IDs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.discid'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('Barcodes:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.barcode'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('IPIs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.ipi'], $c)}</td>
          </tr>
          <tr>
            <th>{l_statistics('ISNIs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.isni'], $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Artists')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Artists')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Artists:')}</th>
            <td>{formatCount(stats.data['count.artist'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Person:')}</th>
            <td>{formatCount(stats.data['count.artist.type.person'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.person'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Group:')}</th>
            <td>{formatCount(stats.data['count.artist.type.group'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.group'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Orchestra:')}</th>
            <td>{formatCount(stats.data['count.artist.type.orchestra'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.orchestra'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Choir:')}</th>
            <td>{formatCount(stats.data['count.artist.type.choir'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.choir'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Character:')}</th>
            <td>{formatCount(stats.data['count.artist.type.character'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.character'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('of type Other:')}</th>
            <td>{formatCount(stats.data['count.artist.type.other'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.other'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no type set:')}</th>
            <td>{formatCount(stats.data['count.artist.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.type.null'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with appearances in artist credits:')}</th>
            <td>{formatCount(stats.data['count.artist.has_credits'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.has_credits'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no appearances in artist credits:')}</th>
            <td>{formatCount(stats.data['count.artist.0credits'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.0credits'] / stats.data['count.artist'], 1, $c)}</td>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Non-group artists:')}</th>
            <td>{formatCount(stats.data['count.artist.type.null'] + stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Male:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.male'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.male'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Female:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.female'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.female'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('Other gender:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.other'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.other'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th>{l_statistics('with no gender set:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.null'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Releases, Data Quality, and Disc IDs')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Releases')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('by various artists:')}</th>
            <td>{formatCount(stats.data['count.release.various'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.various'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('by a single artist:')}</th>
            <td>{formatCount(stats.data['count.release.nonvarious'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.nonvarious'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Release Status')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          {((Object.values(statuses): any): $ReadOnlyArray<ReleaseStatusT>).map(status => (
            <tr key={status.gid}>
              <th />
              <th colSpan="2">{l_statistics(status.name)}</th>
              <td>{formatCount(stats.data['count.release.status.' + status.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.release.status.' + status.id] / stats.data['count.release'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No status set')}</th>
            <td>{formatCount(stats.data['count.release.status.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.status.null'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Release Packaging')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          {((Object.values(packagings): any): $ReadOnlyArray<ReleasePackagingT>).map(packaging => (
            <tr key={packaging.gid}>
              <th />
              <th colSpan="2">{l_statistics(packaging.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.release.packaging.' + packaging.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.release.packaging.' + packaging.id] / stats.data['count.release'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No packaging set')}</th>
            <td>{formatCount(stats.data['count.release.packaging.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.packaging.null'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Cover Art Sources')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('CAA:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.caa'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.caa'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Amazon:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.amazon'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.amazon'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('URL Relationships:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.relationship'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.relationship'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('No front cover art:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.none'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.none'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Data Quality')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('High Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.high'], $c)}</td>
            <td>{formatPercentage(stats.data['count.quality.release.high'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Default Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.default'], $c)}</td>
            <td>{formatPercentage(stats.data['count.quality.release.default'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l_statistics('Normal Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.normal'], $c)}</td>
            <td>{formatPercentage(stats.data['count.quality.release.normal'] / stats.data['count.quality.release.default'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l_statistics('Unknown Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.unknown'], $c)}</td>
            <td>{formatPercentage(stats.data['count.quality.release.unknown'] / stats.data['count.quality.release.default'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Low Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.low'], $c)}</td>
            <td>{formatPercentage(stats.data['count.quality.release.low'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l_statistics('Disc IDs')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Disc IDs:')}</th>
            <td>{formatCount(stats.data['count.discid'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Releases with no disc IDs:')}</th>
            <td>{formatCount(stats.data['count.release.0discids'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.0discids'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Releases with at least one disc ID:')}</th>
            <td>{formatCount(stats.data['count.release.has_discid'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.has_discid'] / stats.data['count.release'], 1, $c)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{ln_statistics('with {num} disc ID:', 'with {num} disc IDs:', num, {__react: true, num: num})}</th>
              <td>{formatCount(stats.data['count.release.' + num + 'discids'], $c)}</td>
              <td>{formatPercentage(stats.data['count.release.' + num + 'discids'] / stats.data['count.release.has_discid'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l_statistics('with 10 or more disc IDs:')}</th>
            <td>{formatCount(stats.data['count.release.10discids'], $c)}</td>
            <td>{formatPercentage(stats.data['count.release.10discids'] / stats.data['count.release.has_discid'], 1, $c)}</td>
          </tr>
          <tr>
            <th colSpan="3">{l_statistics('Mediums:')}</th>
            <td>{formatCount(stats.data['count.medium'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Mediums with no disc IDs:')}</th>
            <td>{formatCount(stats.data['count.medium.0discids'], $c)}</td>
            <td>{formatPercentage(stats.data['count.medium.0discids'] / stats.data['count.medium'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l_statistics('Mediums with at least one disc ID:')}</th>
            <td>{formatCount(stats.data['count.medium.has_discid'], $c)}</td>
            <td>{formatPercentage(stats.data['count.medium.has_discid'] / stats.data['count.medium'], 1, $c)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{ln_statistics('with {num} disc ID:', 'with {num} disc IDs:', num, {__react: true, num: num})}</th>
              <td>{formatCount(stats.data['count.medium.' + num + 'discids'], $c)}</td>
              <td>{formatPercentage(stats.data['count.medium.' + num + 'discids'] / stats.data['count.medium.has_discid'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l_statistics('with 10 or more disc IDs:')}</th>
            <td>{formatCount(stats.data['count.medium.10discids'], $c)}</td>
            <td>{formatPercentage(stats.data['count.medium.10discids'] / stats.data['count.medium.has_discid'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Release Groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Primary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Release Groups:')}</th>
            <td>{formatCount(stats.data['count.releasegroup'], $c)}</td>
            <td />
          </tr>
          {((Object.values(primaryTypes): any): $ReadOnlyArray<ReleaseGroupTypeT>).map(primaryType => (
            <tr key={primaryType.gid}>
              <th />
              <th>{l_statistics(primaryType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.releasegroup.primary_type.' + primaryType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.releasegroup.primary_type.' + primaryType.id] / stats.data['count.releasegroup'], 1, $c)}</td>
            </tr>
          ))}
          <tr className="thead">
            <th colSpan="4">{l_statistics('Secondary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Release Groups:')}</th>
            <td>{formatCount(stats.data['count.releasegroup'], $c)}</td>
            <td />
          </tr>
          {((Object.values(secondaryTypes): any): $ReadOnlyArray<ReleaseGroupSecondaryTypeT>).map(secondaryType => (
            <tr key={secondaryType.gid}>
              <th />
              <th>{l_statistics(secondaryType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.releasegroup.secondary_type.' + secondaryType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.releasegroup.secondary_type.' + secondaryType.id] / stats.data['count.releasegroup'], 1, $c)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>{l_statistics('Recordings')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="3">{l_statistics('Recordings')}</th>
          </tr>
          <tr>
            <th>{l_statistics('Recordings:')}</th>
            <td>{formatCount(stats.data['count.recording'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th>{l_statistics('Videos:')}</th>
            <td>{formatCount(stats.data['count.video'], $c)}</td>
            <td>{formatPercentage(stats.data['count.video'] / stats.data['count.recording'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Labels')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColon(l_statistics('Labels'))}</th>
            <td>{formatCount(stats.data['count.label'], $c)}</td>
            <td />
          </tr>
          {labelTypes.map(labelType => (
            <tr key={labelType.gid}>
              <th />
              <th>{l_statistics(labelType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.label.type.' + labelType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.label.type.' + labelType.id] / stats.data['count.label'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.label.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.label.type.null'] / stats.data['count.label'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Works')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Works:')}</th>
            <td>{formatCount(stats.data['count.work'], $c)}</td>
            <td />
          </tr>
          {workTypes.map(workType => (
            <tr key={workType.gid}>
              <th />
              <th>{l_statistics(workType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.work.type.' + workType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.work.type.' + workType.id] / stats.data['count.work'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.work.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.work.type.null'] / stats.data['count.work'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Attributes')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Works:')}</th>
            <td>{formatCount(stats.data['count.work'], $c)}</td>
            <td />
          </tr>
          {workAttributeTypes.map(workAttributeType => (
            <tr key={workAttributeType.gid}>
              <th />
              <th>{l_statistics(workAttributeType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.work.attribute.' + workAttributeType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.work.attribute.' + workAttributeType.id] / stats.data['count.work'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.work.attribute.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.work.attribute.null'] / stats.data['count.work'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Areas')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Areas:')}</th>
            <td>{formatCount(stats.data['count.area'], $c)}</td>
            <td />
          </tr>
          {areaTypes.map(areaType => (
            <tr key={areaType.gid}>
              <th />
              <th>{l_statistics(areaType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.area.type.' + areaType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.area.type.' + areaType.id] / stats.data['count.area'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.area.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.area.type.null'] / stats.data['count.area'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Places')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Places:')}</th>
            <td>{formatCount(stats.data['count.place'], $c)}</td>
            <td />
          </tr>
          {placeTypes.map(placeType => (
            <tr key={placeType.gid}>
              <th />
              <th>{l_statistics(placeType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.place.type.' + placeType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.place.type.' + placeType.id] / stats.data['count.place'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.place.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.place.type.null'] / stats.data['count.place'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{lp_statistics('Series', 'plural')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{lp_statistics('Series:', 'plural')}</th>
            <td>{formatCount(stats.data['count.series'], $c)}</td>
            <td />
          </tr>
          {seriesTypes.map(seriesType => (
            <tr key={seriesType.gid}>
              <th />
              <th>{l_statistics(seriesType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.series.type.' + seriesType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.series.type.' + seriesType.id] / stats.data['count.series'], 1, $c)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>{l_statistics('Instruments')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Instruments:')}</th>
            <td>{formatCount(stats.data['count.instrument'], $c)}</td>
            <td />
          </tr>
          {instrumentTypes.map(instrumentType => (
            <tr key={instrumentType.gid}>
              <th />
              <th>{l_statistics(instrumentType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.instrument.type.' + instrumentType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.instrument.type.' + instrumentType.id] / stats.data['count.instrument'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.instrument.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.instrument.type.null'] / stats.data['count.instrument'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Events')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l_statistics('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l_statistics('Events:')}</th>
            <td>{formatCount(stats.data['count.event'], $c)}</td>
            <td />
          </tr>
          {eventTypes.map(eventType => (
            <tr key={eventType.gid}>
              <th />
              <th>{l_statistics(eventType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.event.type.' + eventType.id], $c)}</td>
              <td>{formatPercentage(stats.data['count.event.type.' + eventType.id] / stats.data['count.event'], 1, $c)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l_statistics('None')}</th>
            <td>{formatCount(stats.data['count.event.type.null'], $c)}</td>
            <td>{formatPercentage(stats.data['count.event.type.null'] / stats.data['count.event'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l_statistics('Editors, Edits, and Votes')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Editors')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Editors (valid):')}</th>
            <td>{formatCount(stats.data['count.editor.valid'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('active ever:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active'] / stats.data['count.editor.valid'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who edited and/or voted in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.activelastweek'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.activelastweek'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l_statistics('who edited in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.editlastweek'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.editlastweek'] / stats.data['count.editor.activelastweek'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l_statistics('who voted in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.votelastweek'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.votelastweek'] / stats.data['count.editor.activelastweek'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who edit:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.edits'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.edits'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who vote:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.votes'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.votes'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who leave edit notes:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.notes'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.notes'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use tags:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.tags'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.tags'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use ratings:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.ratings'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.ratings'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use subscriptions:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.subscriptions'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.subscriptions'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who use collections:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.collections'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.collections'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('who have registered applications:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.applications'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.applications'] / stats.data['count.editor.valid.active'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('validated email only:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.validated_only'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.validated_only'] / stats.data['count.editor.valid'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('inactive:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.inactive'], $c)}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.inactive'] / stats.data['count.editor.valid'], 1, $c)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Editors (deleted):')}</th>
            <td>{formatCount(stats.data['count.editor.deleted'], $c)}</td>
            <td />
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Edits')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Edits:')}</th>
            <td>{formatCount(stats.data['count.edit'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Open:')}</th>
            <td>{formatCount(stats.data['count.edit.open'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.open'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Applied:')}</th>
            <td>{formatCount(stats.data['count.edit.applied'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.applied'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Voted down:')}</th>
            <td>{formatCount(stats.data['count.edit.failedvote'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.failedvote'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (dependency):')}</th>
            <td>{formatCount(stats.data['count.edit.faileddep'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.faileddep'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (prerequisite):')}</th>
            <td>{formatCount(stats.data['count.edit.failedprereq'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.failedprereq'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Failed (internal error):')}</th>
            <td>{formatCount(stats.data['count.edit.error'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.error'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Cancelled:')}</th>
            <td>{formatCount(stats.data['count.edit.deleted'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.deleted'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Edits:')}</th>
            <td>{formatCount(stats.data['count.edit'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Last 7 days:')}</th>
            <td>{formatCount(stats.data['count.edit.perweek'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.perweek'] / stats.data['count.edit'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2" />
            <th>{l_statistics('Yesterday:')}</th>
            <td>{formatCount(stats.data['count.edit.perday'], $c)}</td>
            <td>{formatPercentage(stats.data['count.edit.perday'] / stats.data['count.edit.perweek'], 1, $c)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l_statistics('Votes')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Votes:')}</th>
            <td>{formatCount(stats.data['count.vote'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp_statistics('Approve', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.approve'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.approve'] / stats.data['count.vote'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp_statistics('Yes', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.yes'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.yes'] / stats.data['count.vote'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp_statistics('No', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.no'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.no'] / stats.data['count.vote'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp_statistics('Abstain', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.abstain'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.abstain'] / stats.data['count.vote'], 1, $c)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l_statistics('Votes:')}</th>
            <td>{formatCount(stats.data['count.vote'], $c)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l_statistics('Last 7 days:')}</th>
            <td>{formatCount(stats.data['count.vote.perweek'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.perweek'] / stats.data['count.vote'], 1, $c)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l_statistics('Yesterday:')}</th>
            <td>{formatCount(stats.data['count.vote.perday'], $c)}</td>
            <td>{formatPercentage(stats.data['count.vote.perday'] / stats.data['count.vote.perweek'], 1, $c)}</td>
          </tr>
        </tbody>
      </table>
    </StatisticsLayout>
  );
};

export default withCatalystContext(Index);
