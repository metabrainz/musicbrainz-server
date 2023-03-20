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

import {CatalystContext} from '../context.mjs';
import {l_statistics as l, lp_statistics as lp}
  from '../static/scripts/common/i18n/statistics.js';
import mapRange from '../static/scripts/common/utility/mapRange.js';

import StatisticsLayout from './StatisticsLayout.js';
import {formatCount, formatPercentage, TimelineLink} from './utilities.js';

type MainStatsT = {
  +areaTypes: $ReadOnlyArray<AreaTypeT>,
  +dateCollected: string,
  +eventTypes: $ReadOnlyArray<EventTypeT>,
  +instrumentTypes: $ReadOnlyArray<InstrumentTypeT>,
  +labelTypes: $ReadOnlyArray<LabelTypeT>,
  +packagings: $ReadOnlyArray<ReleasePackagingT>,
  +placeTypes: $ReadOnlyArray<PlaceTypeT>,
  +primaryTypes: $ReadOnlyArray<ReleaseGroupTypeT>,
  +secondaryTypes: $ReadOnlyArray<ReleaseGroupSecondaryTypeT>,
  +seriesTypes: $ReadOnlyArray<SeriesTypeT>,
  +stats: {[statName: string]: number},
  +statuses: $ReadOnlyArray<ReleaseStatusT>,
  +workAttributeTypes: $ReadOnlyArray<WorkAttributeTypeT>,
  +workTypes: $ReadOnlyArray<WorkTypeT>,
};

const Index = ({
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
}: MainStatsT): React$Element<typeof StatisticsLayout> => {
  const $c = React.useContext(CatalystContext);

  const nonGroupCount = stats['count.artist.type.null'] +
    stats['count.artist.type.person'] +
    stats['count.artist.type.character'] +
    stats['count.artist.type.other'];

  // formatCount shortcut (with timeline link)
  const fc = (a: string) => (
    <>
      {formatCount($c, stats['count.' + a])}
      {' '}
      <TimelineLink statName={'count.' + a} />
    </>
  );

  // formatPercentage shortcut
  const fp = (a: string, b: string) => (
    formatPercentage($c, stats['count.' + a] / stats['count.' + b], 1)
  );

  /*
   * Long-form for cases where `a` or `b` aren't keys in `stats`,
   * but so `$c` and `digits` still don't need to be provided.
   */
  const _formatPercentage =
    (a: number, b: number) => formatPercentage($c, a / b, 1);

  return (
    <StatisticsLayout fullWidth page="index" title={l('Overview')}>
      <p>
        {texp.l('Last updated: {date}', {date: dateCollected})}
      </p>
      <h2>{l('Basic metadata')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Core Entities')}</th>
          </tr>
          <tr>
            <th>{l('Artists:')}</th>
            <td colSpan="3">{fc('artist')}</td>
          </tr>
          <tr>
            <th>{l('Release Groups:')}</th>
            <td colSpan="3">{fc('releasegroup')}</td>
          </tr>
          <tr>
            <th>{l('Releases:')}</th>
            <td colSpan="3">{fc('release')}</td>
          </tr>
          <tr>
            <th>{l('Mediums:')}</th>
            <td colSpan="3">{fc('medium')}</td>
          </tr>
          <tr>
            <th>{l('Recordings:')}</th>
            <td colSpan="3">{fc('recording')}</td>
          </tr>
          <tr>
            <th>{l('Tracks:')}</th>
            <td colSpan="3">{fc('track')}</td>
          </tr>
          <tr>
            <th>{l('Labels:')}</th>
            <td colSpan="3">{fc('label')}</td>
          </tr>
          <tr>
            <th>{l('Works:')}</th>
            <td colSpan="3">{fc('work')}</td>
          </tr>
          <tr>
            <th>{l('URLs:')}</th>
            <td colSpan="3">{fc('url')}</td>
          </tr>
          <tr>
            <th>{l('Areas:')}</th>
            <td colSpan="3">{fc('area')}</td>
          </tr>
          <tr>
            <th>{l('Places:')}</th>
            <td colSpan="3">{fc('place')}</td>
          </tr>
          <tr>
            <th>{lp('Series:', 'plural')}</th>
            <td colSpan="3">{fc('series')}</td>
          </tr>
          <tr>
            <th>{l('Instruments:')}</th>
            <td colSpan="3">{fc('instrument')}</td>
          </tr>
          <tr>
            <th>{l('Events:')}</th>
            <td colSpan="3">{fc('event')}</td>
          </tr>
          <tr>
            <th>{addColonText(l('Genres'))}</th>
            <td colSpan="3">{fc('genre')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Other Entities')}</th>
          </tr>
          <tr>
            <th>{l('Editors (valid / deleted):')}</th>
            <td>{fc('editor.valid')}</td>
            <td>{'/'}</td>
            <td>{fc('editor.deleted')}</td>
          </tr>
          <tr>
            <th>{l('Relationships:')}</th>
            <td colSpan="3">{fc('ar.links')}</td>
          </tr>
          <tr>
            <th>{addColonText(l('Collections'))}</th>
            <td colSpan="3">{fc('collection')}</td>
          </tr>
          <tr>
            <th>{l('CD Stubs (all time / current):')}</th>
            <td>{fc('cdstub.submitted')}</td>
            <td>{'/'}</td>
            <td>
              {' '}
              {fc('cdstub')}
            </td>
          </tr>
          <tr>
            <th>{l('Tags (raw / aggregated):')}</th>
            <td>{fc('tag.raw')}</td>
            <td>{'/'}</td>
            <td>{fc('tag')}</td>
          </tr>
          <tr>
            <th>{l('Ratings (raw / aggregated):')}</th>
            <td>{fc('rating.raw')}</td>
            <td>{'/'}</td>
            <td>{fc('rating')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Identifiers')}</th>
          </tr>
          <tr>
            <th>{l('MBIDs:')}</th>
            <td colSpan="3">{fc('mbid')}</td>
          </tr>
          <tr>
            <th>{l('ISRCs (all / unique):')}</th>
            <td>{fc('isrc.all')}</td>
            <td>{'/'}</td>
            <td>{fc('isrc')}</td>
          </tr>
          <tr>
            <th>{l('ISWCs (all / unique):')}</th>
            <td>{fc('iswc.all')}</td>
            <td>{'/'}</td>
            <td>{fc('iswc')}</td>
          </tr>
          <tr>
            <th>{l('Disc IDs:')}</th>
            <td colSpan="3">{fc('discid')}</td>
          </tr>
          <tr>
            <th>{l('Barcodes:')}</th>
            <td colSpan="3">{fc('barcode')}</td>
          </tr>
          <tr>
            <th>{l('IPIs:')}</th>
            <td colSpan="3">{fc('ipi')}</td>
          </tr>
          <tr>
            <th>{l('ISNIs:')}</th>
            <td colSpan="3">{fc('isni')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Artists')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Artists')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Artists:')}</th>
            <td>{fc('artist')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('of type Person:')}</th>
            <td>{fc('artist.type.person')}</td>
            <td>{fp('artist.type.person', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Group:')}</th>
            <td>{fc('artist.type.group')}</td>
            <td>{fp('artist.type.group', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Orchestra:')}</th>
            <td>{fc('artist.type.orchestra')}</td>
            <td>{fp('artist.type.orchestra', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Choir:')}</th>
            <td>{fc('artist.type.choir')}</td>
            <td>{fp('artist.type.choir', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Character:')}</th>
            <td>{fc('artist.type.character')}</td>
            <td>{fp('artist.type.character', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Other:')}</th>
            <td>{fc('artist.type.other')}</td>
            <td>{fp('artist.type.other', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no type set:')}</th>
            <td>{fc('artist.type.null')}</td>
            <td>{fp('artist.type.null', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with appearances in artist credits:')}</th>
            <td>{fc('artist.has_credits')}</td>
            <td>{fp('artist.has_credits', 'artist')}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no appearances in artist credits:')}</th>
            <td>{fc('artist.0credits')}</td>
            <td>{fp('artist.0credits', 'artist')}</td>
          </tr>
          <tr>
            <th colSpan="2">{l('Non-group artists:')}</th>
            <td>{formatCount($c, nonGroupCount)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('Male:')}</th>
            <td>{fc('artist.gender.male')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.male'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l('Female:')}</th>
            <td>{fc('artist.gender.female')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.female'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{addColonText(l('Non-binary'))}</th>
            <td>{fc('artist.gender.nonbinary')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.nonbinary'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l('Other gender:')}</th>
            <td>{fc('artist.gender.other')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.other'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l('Gender not applicable:')}</th>
            <td>{fc('artist.gender.not_applicable')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.not_applicable'],
                nonGroupCount,
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th>{l('with no gender set:')}</th>
            <td>{fc('artist.gender.null')}</td>
            <td>
              {_formatPercentage(
                stats['count.artist.gender.null'],
                nonGroupCount,
              )}
            </td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Releases, Data Quality, and Disc IDs')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Releases')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by various artists:')}</th>
            <td>{fc('release.various')}</td>
            <td>{fp('release.various', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by a single artist:')}</th>
            <td>{fc('release.nonvarious')}</td>
            <td>{fp('release.nonvarious', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Status')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          {statuses.map(status => (
            <tr key={status.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(status.name, 'release_status')}
              </th>
              <td>{fc('release.status.' + status.id)}</td>
              <td>{fp('release.status.' + status.id, 'release')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No status set')}</th>
            <td>{fc('release.status.null')}</td>
            <td>{fp('release.status.null', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Packaging')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          {packagings.map(packaging => (
            <tr key={packaging.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(packaging.name, 'release_packaging')}
              </th>
              <td>{fc('release.packaging.' + packaging.id)}</td>
              <td>{fp('release.packaging.' + packaging.id, 'release')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No packaging set')}</th>
            <td>{fc('release.packaging.null')}</td>
            <td>{fp('release.packaging.null', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Cover Art Sources')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('CAA:')}</th>
            <td>{fc('release.coverart.caa')}</td>
            <td>{fp('release.coverart.caa', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('No front cover art:')}</th>
            <td>{fc('release.coverart.none')}</td>
            <td>{fp('release.coverart.none', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Data Quality')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('High Data Quality:')}</th>
            <td>{fc('quality.release.high')}</td>
            <td>{fp('quality.release.high', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Default Data Quality:')}</th>
            <td>{fc('quality.release.default')}</td>
            <td>{fp('quality.release.default', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Normal Data Quality:')}</th>
            <td>{fc('quality.release.normal')}</td>
            <td>{fp('quality.release.normal', 'quality.release.default')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Unknown Data Quality:')}</th>
            <td>{fc('quality.release.unknown')}</td>
            <td>
              {fp('quality.release.unknown', 'quality.release.default')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Low Data Quality:')}</th>
            <td>{fc('quality.release.low')}</td>
            <td>{fp('quality.release.low', 'release')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Disc IDs')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Disc IDs:')}</th>
            <td>{fc('discid')}</td>
            <td />
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{fc('release')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Releases with no disc IDs:')}</th>
            <td>{fc('release.0discids')}</td>
            <td>{fp('release.0discids', 'release')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l('Releases with at least one disc ID:')}
            </th>
            <td>{fc('release.has_discid')}</td>
            <td>{fp('release.has_discid', 'release')}</td>
          </tr>
          {mapRange(1, 9, (num) => (
            <tr key={num}>
              <th />
              <th />
              <th>
                {texp.ln(
                  'with {num} disc ID:',
                  'with {num} disc IDs:',
                  num,
                  {num: num},
                )}
              </th>
              <td>{fc('release.' + num + 'discids')}</td>
              <td>
                {fp('release.' + num + 'discids', 'release.has_discid')}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{fc('release.10discids')}</td>
            <td>{fp('release.10discids', 'release.has_discid')}</td>
          </tr>
          <tr>
            <th colSpan="3">{l('Mediums:')}</th>
            <td>{fc('medium')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Mediums with no disc IDs:')}</th>
            <td>{fc('medium.0discids')}</td>
            <td>{fp('medium.0discids', 'medium')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l('Mediums with at least one disc ID:')}
            </th>
            <td>{fc('medium.has_discid')}</td>
            <td>{fp('medium.has_discid', 'medium')}</td>
          </tr>
          {mapRange(1, 9, (num) => (
            <tr key={num}>
              <th />
              <th />
              <th>
                {texp.ln(
                  'with {num} disc ID:',
                  'with {num} disc IDs:',
                  num,
                  {num: num},
                )}
              </th>
              <td>{fc('medium.' + num + 'discids')}</td>
              <td>{fp('medium.' + num + 'discids', 'medium.has_discid')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{fc('medium.10discids')}</td>
            <td>{fp('medium.10discids', 'medium.has_discid')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Release Groups')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Primary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Release Groups:')}</th>
            <td>{fc('releasegroup')}</td>
            <td />
          </tr>
          {primaryTypes.map(primaryType => (
            <tr key={primaryType.gid}>
              <th />
              <th>
                {lp_attributes(
                  primaryType.name,
                  'release_group_primary_type',
                )}
              </th>
              <td>{fc('releasegroup.primary_type.' + primaryType.id)}</td>
              <td>
                {fp(
                  'releasegroup.primary_type.' + primaryType.id,
                  'releasegroup',
                )}
              </td>
            </tr>
          ))}
          <tr className="thead">
            <th colSpan="4">{l('Secondary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Release Groups:')}</th>
            <td>{fc('releasegroup')}</td>
            <td />
          </tr>
          {secondaryTypes.map(secondaryType => (
            <tr key={secondaryType.gid}>
              <th />
              <th>
                {lp_attributes(
                  secondaryType.name,
                  'release_group_secondary_type',
                )}
              </th>
              <td>{fc('releasegroup.secondary_type.' + secondaryType.id)}</td>
              <td>
                {fp(
                  'releasegroup.secondary_type.' + secondaryType.id,
                  'releasegroup',
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>{l('Recordings')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="3">{l('Recordings')}</th>
          </tr>
          <tr>
            <th>{l('Recordings:')}</th>
            <td>{fc('recording')}</td>
            <td />
          </tr>
          <tr>
            <th>{l('Videos:')}</th>
            <td>{fc('video')}</td>
            <td>{fp('video', 'recording')}</td>
          </tr>
          <tr>
            <th>{addColonText(lp('Standalone', 'recording'))}</th>
            <td>{fc('recording.standalone')}</td>
            <td>{fp('recording.standalone', 'recording')}</td>
          </tr>
          <tr>
            <th>{addColonText(l('With ISRCs'))}</th>
            <td>{fc('recording.has_isrc')}</td>
            <td>{fp('recording.has_isrc', 'recording')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Labels')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{addColonText(l('Labels'))}</th>
            <td>{fc('label')}</td>
            <td />
          </tr>
          {labelTypes.map(labelType => (
            <tr key={labelType.gid}>
              <th />
              <th>{lp_attributes(labelType.name, 'label_type')}</th>
              <td>{fc('label.type.' + labelType.id)}</td>
              <td>{fp('label.type.' + labelType.id, 'label')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('label.type.null')}</td>
            <td>{fp('label.type.null', 'label')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Works')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Works:')}</th>
            <td>{fc('work')}</td>
            <td />
          </tr>
          {workTypes.map(workType => (
            <tr key={workType.gid}>
              <th />
              <th>{lp_attributes(workType.name, 'work_type')}</th>
              <td>{fc('work.type.' + workType.id)}</td>
              <td>{fp('work.type.' + workType.id, 'work')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('work.type.null')}</td>
            <td>{fp('work.type.null', 'work')}</td>
          </tr>
          <tr>
            <th>{addColonText(l('With ISWCs'))}</th>
            <td>{fc('work.has_iswc')}</td>
            <td>{fp('work.has_iswc', 'work')}</td>
          </tr>
        </tbody>
      </table>

      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Attributes')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Works:')}</th>
            <td>{fc('work')}</td>
            <td />
          </tr>
          {workAttributeTypes.map(workAttributeType => (
            <tr key={workAttributeType.gid}>
              <th />
              <th>
                {lp_attributes(workAttributeType.name, 'work_attribute_type')}
              </th>
              <td>{fc('work.attribute.' + workAttributeType.id)}</td>
              <td>{fp('work.attribute.' + workAttributeType.id, 'work')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('work.attribute.null')}</td>
            <td>{fp('work.attribute.null', 'work')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Areas')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Areas:')}</th>
            <td>{fc('area')}</td>
            <td />
          </tr>
          {areaTypes.map(areaType => (
            <tr key={areaType.gid}>
              <th />
              <th>{lp_attributes(areaType.name, 'area_type')}</th>
              <td>{fc('area.type.' + areaType.id)}</td>
              <td>{fp('area.type.' + areaType.id, 'area')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('area.type.null')}</td>
            <td>{fp('area.type.null', 'area')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Places')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Places:')}</th>
            <td>{fc('place')}</td>
            <td />
          </tr>
          {placeTypes.map(placeType => (
            <tr key={placeType.gid}>
              <th />
              <th>{lp_attributes(placeType.name, 'place_type')}</th>
              <td>{fc('place.type.' + placeType.id)}</td>
              <td>{fp('place.type.' + placeType.id, 'place')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('place.type.null')}</td>
            <td>{fp('place.type.null', 'place')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{lp('Series', 'plural')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{lp('Series:', 'plural')}</th>
            <td>{fc('series')}</td>
            <td />
          </tr>
          {seriesTypes.map(seriesType => (
            <tr key={seriesType.gid}>
              <th />
              <th>{lp_attributes(seriesType.name, 'series_type')}</th>
              <td>{fc('series.type.' + seriesType.id)}</td>
              <td>{fp('series.type.' + seriesType.id, 'series')}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>{l('Instruments')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Instruments:')}</th>
            <td>{fc('instrument')}</td>
            <td />
          </tr>
          {instrumentTypes.map(instrumentType => (
            <tr key={instrumentType.gid}>
              <th />
              <th>{lp_attributes(instrumentType.name, 'instrument_type')}</th>
              <td>{fc('instrument.type.' + instrumentType.id)}</td>
              <td>
                {fp('instrument.type.' + instrumentType.id, 'instrument')}
              </td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('instrument.type.null')}</td>
            <td>{fp('instrument.type.null', 'instrument')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Events')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Events:')}</th>
            <td>{fc('event')}</td>
            <td />
          </tr>
          {eventTypes.map(eventType => (
            <tr key={eventType.gid}>
              <th />
              <th>{lp_attributes(eventType.name, 'event_type')}</th>
              <td>{fc('event.type.' + eventType.id)}</td>
              <td>{fp('event.type.' + eventType.id, 'event')}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{fc('event.type.null')}</td>
            <td>{fp('event.type.null', 'event')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Collections')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Collections')}</th>
          </tr>
          <tr>
            <th colSpan="3">{addColonText(l('Collections'))}</th>
            <td>{fc('collection')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of releases'))}</th>
            <td>{fc('collection.type.release.all')}</td>
            <td>{fp('collection.type.release.all', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Generic'))}</th>
            <td>{fc('collection.type.release')}</td>
            <td>
              {fp('collection.type.release', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Owned music'))}</th>
            <td>{fc('collection.type.owned')}</td>
            <td>
              {fp('collection.type.owned', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Wishlist'))}</th>
            <td>{fc('collection.type.wishlist')}</td>
            <td>
              {fp('collection.type.wishlist', 'collection.type.release.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of events'))}</th>
            <td>{fc('collection.type.event.all')}</td>
            <td>{fp('collection.type.event.all', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Generic'))}</th>
            <td>{fc('collection.type.event')}</td>
            <td>
              {fp('collection.type.event', 'collection.type.event.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Of type Attending'))}</th>
            <td>{fc('collection.type.attending')}</td>
            <td>
              {fp('collection.type.attending', 'collection.type.event.all')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{addColonText(l('Of type Maybe attending'))}</th>
            <td>{fc('collection.type.maybe_attending')}</td>
            <td>
              {fp(
                'collection.type.maybe_attending',
                'collection.type.event.all',
              )}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of areas'))}</th>
            <td>{fc('collection.type.area')}</td>
            <td>{fp('collection.type.area', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of artists'))}</th>
            <td>{fc('collection.type.artist')}</td>
            <td>{fp('collection.type.artist', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of instruments'))}</th>
            <td>{fc('collection.type.instrument')}</td>
            <td>{fp('collection.type.instrument', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of labels'))}</th>
            <td>{fc('collection.type.label')}</td>
            <td>{fp('collection.type.label', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of places'))}</th>
            <td>{fc('collection.type.place')}</td>
            <td>{fp('collection.type.place', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of recordings'))}</th>
            <td>{fc('collection.type.recording')}</td>
            <td>{fp('collection.type.recording', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of release groups'))}</th>
            <td>{fc('collection.type.release_group')}</td>
            <td>{fp('collection.type.release_group', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of series'))}</th>
            <td>{fc('collection.type.series')}</td>
            <td>{fp('collection.type.series', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Of works'))}</th>
            <td>{fc('collection.type.work')}</td>
            <td>{fp('collection.type.work', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Public'))}</th>
            <td>{fc('collection.public')}</td>
            <td>{fp('collection.public', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('Private'))}</th>
            <td>{fc('collection.private')}</td>
            <td>{fp('collection.private', 'collection')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{addColonText(l('With collaborators'))}</th>
            <td>{fc('collection.has_collaborators')}</td>
            <td>{fp('collection.has_collaborators', 'collection')}</td>
          </tr>
        </tbody>
      </table>

      <h2>{l('Editors, Edits, and Votes')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Editors')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Editors (valid):')}</th>
            <td>{fc('editor.valid')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('active ever:')}</th>
            <td>{fc('editor.valid.active')}</td>
            <td>{fp('editor.valid.active', 'editor.valid')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l('who edited and/or voted in the last 7 days:')}
            </th>
            <td>{fc('editor.activelastweek')}</td>
            <td>{fp('editor.activelastweek', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who edited in the last 7 days:')}</th>
            <td>{fc('editor.editlastweek')}</td>
            <td>{fp('editor.editlastweek', 'editor.activelastweek')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who voted in the last 7 days:')}</th>
            <td>{fc('editor.votelastweek')}</td>
            <td>{fp('editor.votelastweek', 'editor.activelastweek')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who edit:')}</th>
            <td>{fc('editor.valid.active.edits')}</td>
            <td>{fp('editor.valid.active.edits', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who vote:')}</th>
            <td>{fc('editor.valid.active.votes')}</td>
            <td>{fp('editor.valid.active.votes', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who leave edit notes:')}</th>
            <td>{fc('editor.valid.active.notes')}</td>
            <td>{fp('editor.valid.active.notes', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use tags:')}</th>
            <td>{fc('editor.valid.active.tags')}</td>
            <td>{fp('editor.valid.active.tags', 'editor.valid.active')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use ratings:')}</th>
            <td>{fc('editor.valid.active.ratings')}</td>
            <td>
              {fp('editor.valid.active.ratings', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use subscriptions:')}</th>
            <td>{fc('editor.valid.active.subscriptions')}</td>
            <td>
              {fp('editor.valid.active.subscriptions', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use collections:')}</th>
            <td>{fc('editor.valid.active.collections')}</td>
            <td>
              {fp('editor.valid.active.collections', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l('who have registered applications:')}
            </th>
            <td>{fc('editor.valid.active.applications')}</td>
            <td>
              {fp('editor.valid.active.applications', 'editor.valid.active')}
            </td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('validated email only:')}</th>
            <td>{fc('editor.valid.validated_only')}</td>
            <td>{fp('editor.valid.validated_only', 'editor.valid')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('inactive:')}</th>
            <td>{fc('editor.valid.inactive')}</td>
            <td>{fp('editor.valid.inactive', 'editor.valid')}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Editors (deleted):')}</th>
            <td>{fc('editor.deleted')}</td>
            <td />
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Edits')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{fc('edit')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Open:')}</th>
            <td>{fc('edit.open')}</td>
            <td>{fp('edit.open', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Applied:')}</th>
            <td>{fc('edit.applied')}</td>
            <td>{fp('edit.applied', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Voted down:')}</th>
            <td>{fc('edit.failedvote')}</td>
            <td>{fp('edit.failedvote', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (dependency):')}</th>
            <td>{fc('edit.faileddep')}</td>
            <td>{fp('edit.faileddep', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (prerequisite):')}</th>
            <td>{fc('edit.failedprereq')}</td>
            <td>{fp('edit.failedprereq', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (internal error):')}</th>
            <td>{fc('edit.error')}</td>
            <td>{fp('edit.error', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Cancelled:')}</th>
            <td>{fc('edit.deleted')}</td>
            <td>{fp('edit.deleted', 'edit')}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{fc('edit')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{fc('edit.perweek')}</td>
            <td>{fp('edit.perweek', 'edit')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2" />
            <th>{l('Yesterday:')}</th>
            <td>{fc('edit.perday')}</td>
            <td>{fp('edit.perday', 'edit.perweek')}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Votes')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{fc('vote')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp('Approve', 'vote'))}</th>
            <td>{fc('vote.approve')}</td>
            <td>{fp('vote.approve', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp('Yes', 'vote'))}</th>
            <td>{fc('vote.yes')}</td>
            <td>{fp('vote.yes', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp('No', 'vote'))}</th>
            <td>{fc('vote.no')}</td>
            <td>{fp('vote.no', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColonText(lp('Abstain', 'vote'))}</th>
            <td>{fc('vote.abstain')}</td>
            <td>{fp('vote.abstain', 'vote')}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{fc('vote')}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{fc('vote.perweek')}</td>
            <td>{fp('vote.perweek', 'vote')}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('Yesterday:')}</th>
            <td>{fc('vote.perday')}</td>
            <td>{fp('vote.perday', 'vote.perweek')}</td>
          </tr>
        </tbody>
      </table>
    </StatisticsLayout>
  );
};

export default Index;
