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
import {range} from 'lodash';

import {l_statistics as l, ln_statistics as ln, lp_statistics as lp} from '../static/scripts/common/i18n/statistics';
import {withCatalystContext} from '../context';

import {formatCount, formatPercentage} from './utilities';
import StatisticsLayout from './StatisticsLayout';

type MainStatsT = {|
  +$c: CatalystContextT,
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
  +stats: {[string]: number},
  +statuses: $ReadOnlyArray<ReleaseStatusT>,
  +workAttributeTypes: $ReadOnlyArray<WorkAttributeTypeT>,
  +workTypes: $ReadOnlyArray<WorkTypeT>,
|};

const oneToNine = range(1, 10);

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
  const nonGroupCount = stats['count.artist.type.null'] +
    stats['count.artist.type.person'] +
    stats['count.artist.type.character'] +
    stats['count.artist.type.other'];

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
            <td colSpan="3">{formatCount($c, stats['count.artist'])}</td>
          </tr>
          <tr>
            <th>{l('Release Groups:')}</th>
            <td colSpan="3">
              {formatCount($c, stats['count.releasegroup'])}
            </td>
          </tr>
          <tr>
            <th>{l('Releases:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.release'])}</td>
          </tr>
          <tr>
            <th>{l('Mediums:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.medium'])}</td>
          </tr>
          <tr>
            <th>{l('Recordings:')}</th>
            <td colSpan="3">
              {formatCount($c, stats['count.recording'])}
            </td>
          </tr>
          <tr>
            <th>{l('Tracks:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.track'])}</td>
          </tr>
          <tr>
            <th>{l('Labels:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.label'])}</td>
          </tr>
          <tr>
            <th>{l('Works:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.work'])}</td>
          </tr>
          <tr>
            <th>{l('URLs:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.url'])}</td>
          </tr>
          <tr>
            <th>{l('Areas:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.area'])}</td>
          </tr>
          <tr>
            <th>{l('Places:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.place'])}</td>
          </tr>
          <tr>
            <th>{lp('Series:', 'plural')}</th>
            <td colSpan="3">{formatCount($c, stats['count.series'])}</td>
          </tr>
          <tr>
            <th>{l('Instruments:')}</th>
            <td colSpan="3">
              {formatCount($c, stats['count.instrument'])}
            </td>
          </tr>
          <tr>
            <th>{l('Events:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.event'])}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Other Entities')}</th>
          </tr>
          <tr>
            <th>{l('Editors (valid / deleted):')}</th>
            <td>{formatCount($c, stats['count.editor.valid'])}</td>
            <td>{'/'}</td>
            <td>{formatCount($c, stats['count.editor.deleted'])}</td>
          </tr>
          <tr>
            <th>{l('Relationships:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.ar.links'])}</td>
          </tr>
          <tr>
            <th>{l('CD Stubs (all time / current):')}</th>
            <td>{formatCount($c, stats['count.cdstub.submitted'])}</td>
            <td>{'/'}</td>
            <td>
              {' '}
              {formatCount($c, stats['count.cdstub'])}
            </td>
          </tr>
          <tr>
            <th>{l('Tags (raw / aggregated):')}</th>
            <td>
              {formatCount($c, stats['count.tag.raw'])}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount($c, stats['count.tag'])}
            </td>
          </tr>
          <tr>
            <th>{l('Ratings (raw / aggregated):')}</th>
            <td>
              {formatCount($c, stats['count.rating.raw'])}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount($c, stats['count.rating'])}
            </td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Identifiers')}</th>
          </tr>
          <tr>
            <th>{l('MBIDs:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.mbid'])}</td>
          </tr>
          <tr>
            <th>{l('ISRCs (all / unique):')}</th>
            <td>{formatCount($c, stats['count.isrc.all'])}</td>
            <td>{'/'}</td>
            <td>{formatCount($c, stats['count.isrc'])}</td>
          </tr>
          <tr>
            <th>{l('ISWCs (all / unique):')}</th>
            <td>{formatCount($c, stats['count.iswc.all'])}</td>
            <td>{'/'}</td>
            <td>{formatCount($c, stats['count.iswc'])}</td>
          </tr>
          <tr>
            <th>{l('Disc IDs:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.discid'])}</td>
          </tr>
          <tr>
            <th>{l('Barcodes:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.barcode'])}</td>
          </tr>
          <tr>
            <th>{l('IPIs:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.ipi'])}</td>
          </tr>
          <tr>
            <th>{l('ISNIs:')}</th>
            <td colSpan="3">{formatCount($c, stats['count.isni'])}</td>
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
            <td>{formatCount($c, stats['count.artist'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('of type Person:')}</th>
            <td>{formatCount($c, stats['count.artist.type.person'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.person'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Group:')}</th>
            <td>{formatCount($c, stats['count.artist.type.group'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.group'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Orchestra:')}</th>
            <td>{formatCount($c, stats['count.artist.type.orchestra'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.orchestra'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Choir:')}</th>
            <td>{formatCount($c, stats['count.artist.type.choir'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.choir'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Character:')}</th>
            <td>{formatCount($c, stats['count.artist.type.character'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.character'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Other:')}</th>
            <td>{formatCount($c, stats['count.artist.type.other'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.other'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no type set:')}</th>
            <td>{formatCount($c, stats['count.artist.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.artist.type.null'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with appearances in artist credits:')}</th>
            <td>{formatCount($c, stats['count.artist.has_credits'])}</td>
            <td>{formatPercentage($c, stats['count.artist.has_credits'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no appearances in artist credits:')}</th>
            <td>{formatCount($c, stats['count.artist.0credits'])}</td>
            <td>{formatPercentage($c, stats['count.artist.0credits'] / stats['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="2">{l('Non-group artists:')}</th>
            <td>{formatCount($c, nonGroupCount)}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('Male:')}</th>
            <td>{formatCount($c, stats['count.artist.gender.male'])}</td>
            <td>{formatPercentage($c, stats['count.artist.gender.male'] / nonGroupCount, 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('Female:')}</th>
            <td>{formatCount($c, stats['count.artist.gender.female'])}</td>
            <td>{formatPercentage($c, stats['count.artist.gender.female'] / nonGroupCount, 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('Other gender:')}</th>
            <td>{formatCount($c, stats['count.artist.gender.other'])}</td>
            <td>{formatPercentage($c, stats['count.artist.gender.other'] / nonGroupCount, 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('Gender not applicable:')}</th>
            <td>{formatCount($c, stats['count.artist.gender.not_applicable'])}</td>
            <td>{formatPercentage($c, stats['count.artist.gender.not_applicable'] / nonGroupCount, 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no gender set:')}</th>
            <td>{formatCount($c, stats['count.artist.gender.null'])}</td>
            <td>{formatPercentage($c, stats['count.artist.gender.null'] / nonGroupCount, 1)}</td>
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
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by various artists:')}</th>
            <td>{formatCount($c, stats['count.release.various'])}</td>
            <td>{formatPercentage($c, stats['count.release.various'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by a single artist:')}</th>
            <td>{formatCount($c, stats['count.release.nonvarious'])}</td>
            <td>{formatPercentage($c, stats['count.release.nonvarious'] / stats['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Status')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          {statuses.map(status => (
            <tr key={status.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(status.name, 'release_status')}
              </th>
              <td>{formatCount($c, stats['count.release.status.' + status.id])}</td>
              <td>{formatPercentage($c, stats['count.release.status.' + status.id] / stats['count.release'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No status set')}</th>
            <td>{formatCount($c, stats['count.release.status.null'])}</td>
            <td>{formatPercentage($c, stats['count.release.status.null'] / stats['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Packaging')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          {packagings.map(packaging => (
            <tr key={packaging.gid}>
              <th />
              <th colSpan="2">
                {lp_attributes(packaging.name, 'release_packaging')}
              </th>
              <td>{formatCount($c, stats['count.release.packaging.' + packaging.id])}</td>
              <td>{formatPercentage($c, stats['count.release.packaging.' + packaging.id] / stats['count.release'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No packaging set')}</th>
            <td>{formatCount($c, stats['count.release.packaging.null'])}</td>
            <td>{formatPercentage($c, stats['count.release.packaging.null'] / stats['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Cover Art Sources')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('CAA:')}</th>
            <td>{formatCount($c, stats['count.release.coverart.caa'])}</td>
            <td>{formatPercentage($c, stats['count.release.coverart.caa'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Amazon:')}</th>
            <td>{formatCount($c, stats['count.release.coverart.amazon'])}</td>
            <td>{formatPercentage($c, stats['count.release.coverart.amazon'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('URL Relationships:')}</th>
            <td>{formatCount($c, stats['count.release.coverart.relationship'])}</td>
            <td>{formatPercentage($c, stats['count.release.coverart.relationship'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('No front cover art:')}</th>
            <td>{formatCount($c, stats['count.release.coverart.none'])}</td>
            <td>{formatPercentage($c, stats['count.release.coverart.none'] / stats['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Data Quality')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('High Data Quality:')}</th>
            <td>{formatCount($c, stats['count.quality.release.high'])}</td>
            <td>{formatPercentage($c, stats['count.quality.release.high'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Default Data Quality:')}</th>
            <td>{formatCount($c, stats['count.quality.release.default'])}</td>
            <td>{formatPercentage($c, stats['count.quality.release.default'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Normal Data Quality:')}</th>
            <td>{formatCount($c, stats['count.quality.release.normal'])}</td>
            <td>{formatPercentage($c, stats['count.quality.release.normal'] / stats['count.quality.release.default'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Unknown Data Quality:')}</th>
            <td>{formatCount($c, stats['count.quality.release.unknown'])}</td>
            <td>{formatPercentage($c, stats['count.quality.release.unknown'] / stats['count.quality.release.default'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Low Data Quality:')}</th>
            <td>{formatCount($c, stats['count.quality.release.low'])}</td>
            <td>{formatPercentage($c, stats['count.quality.release.low'] / stats['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Disc IDs')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Disc IDs:')}</th>
            <td>{formatCount($c, stats['count.discid'])}</td>
            <td />
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount($c, stats['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Releases with no disc IDs:')}</th>
            <td>{formatCount($c, stats['count.release.0discids'])}</td>
            <td>{formatPercentage($c, stats['count.release.0discids'] / stats['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l('Releases with at least one disc ID:')}
            </th>
            <td>{formatCount($c, stats['count.release.has_discid'])}</td>
            <td>{formatPercentage($c, stats['count.release.has_discid'] / stats['count.release'], 1)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{texp.ln('with {num} disc ID:', 'with {num} disc IDs:', num, {num: num})}</th>
              <td>{formatCount($c, stats['count.release.' + num + 'discids'])}</td>
              <td>{formatPercentage($c, stats['count.release.' + num + 'discids'] / stats['count.release.has_discid'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{formatCount($c, stats['count.release.10discids'])}</td>
            <td>{formatPercentage($c, stats['count.release.10discids'] / stats['count.release.has_discid'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="3">{l('Mediums:')}</th>
            <td>{formatCount($c, stats['count.medium'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Mediums with no disc IDs:')}</th>
            <td>{formatCount($c, stats['count.medium.0discids'])}</td>
            <td>{formatPercentage($c, stats['count.medium.0discids'] / stats['count.medium'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">
              {l('Mediums with at least one disc ID:')}
            </th>
            <td>{formatCount($c, stats['count.medium.has_discid'])}</td>
            <td>{formatPercentage($c, stats['count.medium.has_discid'] / stats['count.medium'], 1)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{texp.ln('with {num} disc ID:', 'with {num} disc IDs:', num, {num: num})}</th>
              <td>{formatCount($c, stats['count.medium.' + num + 'discids'])}</td>
              <td>{formatPercentage($c, stats['count.medium.' + num + 'discids'] / stats['count.medium.has_discid'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{formatCount($c, stats['count.medium.10discids'])}</td>
            <td>{formatPercentage($c, stats['count.medium.10discids'] / stats['count.medium.has_discid'], 1)}</td>
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
            <td>{formatCount($c, stats['count.releasegroup'])}</td>
            <td />
          </tr>
          {primaryTypes.map(primaryType => (
            <tr key={primaryType.gid}>
              <th />
              <th>{lp_attributes(primaryType.name, 'release_group_primary_type')}</th>
              <td>{formatCount($c, stats['count.releasegroup.primary_type.' + primaryType.id])}</td>
              <td>{formatPercentage($c, stats['count.releasegroup.primary_type.' + primaryType.id] / stats['count.releasegroup'], 1)}</td>
            </tr>
          ))}
          <tr className="thead">
            <th colSpan="4">{l('Secondary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Release Groups:')}</th>
            <td>{formatCount($c, stats['count.releasegroup'])}</td>
            <td />
          </tr>
          {secondaryTypes.map(secondaryType => (
            <tr key={secondaryType.gid}>
              <th />
              <th>{lp_attributes(secondaryType.name, 'release_group_secondary_type')}</th>
              <td>{formatCount($c, stats['count.releasegroup.secondary_type.' + secondaryType.id])}</td>
              <td>{formatPercentage($c, stats['count.releasegroup.secondary_type.' + secondaryType.id] / stats['count.releasegroup'], 1)}</td>
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
            <td>{formatCount($c, stats['count.recording'])}</td>
            <td />
          </tr>
          <tr>
            <th>{l('Videos:')}</th>
            <td>{formatCount($c, stats['count.video'])}</td>
            <td>{formatPercentage($c, stats['count.video'] / stats['count.recording'], 1)}</td>
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
            <th colSpan="2">{addColon(l('Labels'))}</th>
            <td>{formatCount($c, stats['count.label'])}</td>
            <td />
          </tr>
          {labelTypes.map(labelType => (
            <tr key={labelType.gid}>
              <th />
              <th>{lp_attributes(labelType.name, 'label_type')}</th>
              <td>{formatCount($c, stats['count.label.type.' + labelType.id])}</td>
              <td>{formatPercentage($c, stats['count.label.type.' + labelType.id] / stats['count.label'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.label.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.label.type.null'] / stats['count.label'], 1)}</td>
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
            <td>{formatCount($c, stats['count.work'])}</td>
            <td />
          </tr>
          {workTypes.map(workType => (
            <tr key={workType.gid}>
              <th />
              <th>{lp_attributes(workType.name, 'work_type')}</th>
              <td>{formatCount($c, stats['count.work.type.' + workType.id])}</td>
              <td>{formatPercentage($c, stats['count.work.type.' + workType.id] / stats['count.work'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.work.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.work.type.null'] / stats['count.work'], 1)}</td>
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
            <td>{formatCount($c, stats['count.work'])}</td>
            <td />
          </tr>
          {workAttributeTypes.map(workAttributeType => (
            <tr key={workAttributeType.gid}>
              <th />
              <th>{lp_attributes(workAttributeType.name, 'work_attribute_type')}</th>
              <td>{formatCount($c, stats['count.work.attribute.' + workAttributeType.id])}</td>
              <td>{formatPercentage($c, stats['count.work.attribute.' + workAttributeType.id] / stats['count.work'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.work.attribute.null'])}</td>
            <td>{formatPercentage($c, stats['count.work.attribute.null'] / stats['count.work'], 1)}</td>
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
            <td>{formatCount($c, stats['count.area'])}</td>
            <td />
          </tr>
          {areaTypes.map(areaType => (
            <tr key={areaType.gid}>
              <th />
              <th>{lp_attributes(areaType.name, 'area_type')}</th>
              <td>{formatCount($c, stats['count.area.type.' + areaType.id])}</td>
              <td>{formatPercentage($c, stats['count.area.type.' + areaType.id] / stats['count.area'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.area.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.area.type.null'] / stats['count.area'], 1)}</td>
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
            <td>{formatCount($c, stats['count.place'])}</td>
            <td />
          </tr>
          {placeTypes.map(placeType => (
            <tr key={placeType.gid}>
              <th />
              <th>{lp_attributes(placeType.name, 'place_type')}</th>
              <td>{formatCount($c, stats['count.place.type.' + placeType.id])}</td>
              <td>{formatPercentage($c, stats['count.place.type.' + placeType.id] / stats['count.place'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.place.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.place.type.null'] / stats['count.place'], 1)}</td>
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
            <td>{formatCount($c, stats['count.series'])}</td>
            <td />
          </tr>
          {seriesTypes.map(seriesType => (
            <tr key={seriesType.gid}>
              <th />
              <th>{lp_attributes(seriesType.name, 'series_type')}</th>
              <td>{formatCount($c, stats['count.series.type.' + seriesType.id])}</td>
              <td>{formatPercentage($c, stats['count.series.type.' + seriesType.id] / stats['count.series'], 1)}</td>
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
            <td>{formatCount($c, stats['count.instrument'])}</td>
            <td />
          </tr>
          {instrumentTypes.map(instrumentType => (
            <tr key={instrumentType.gid}>
              <th />
              <th>{lp_attributes(instrumentType.name, 'instrument_type')}</th>
              <td>{formatCount($c, stats['count.instrument.type.' + instrumentType.id])}</td>
              <td>{formatPercentage($c, stats['count.instrument.type.' + instrumentType.id] / stats['count.instrument'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.instrument.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.instrument.type.null'] / stats['count.instrument'], 1)}</td>
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
            <td>{formatCount($c, stats['count.event'])}</td>
            <td />
          </tr>
          {eventTypes.map(eventType => (
            <tr key={eventType.gid}>
              <th />
              <th>{lp_attributes(eventType.name, 'event_type')}</th>
              <td>{formatCount($c, stats['count.event.type.' + eventType.id])}</td>
              <td>{formatPercentage($c, stats['count.event.type.' + eventType.id] / stats['count.event'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount($c, stats['count.event.type.null'])}</td>
            <td>{formatPercentage($c, stats['count.event.type.null'] / stats['count.event'], 1)}</td>
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
            <td>{formatCount($c, stats['count.editor.valid'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('active ever:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active'] / stats['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l('who edited and/or voted in the last 7 days:')}
            </th>
            <td>{formatCount($c, stats['count.editor.activelastweek'])}</td>
            <td>{formatPercentage($c, stats['count.editor.activelastweek'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who edited in the last 7 days:')}</th>
            <td>{formatCount($c, stats['count.editor.editlastweek'])}</td>
            <td>{formatPercentage($c, stats['count.editor.editlastweek'] / stats['count.editor.activelastweek'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who voted in the last 7 days:')}</th>
            <td>{formatCount($c, stats['count.editor.votelastweek'])}</td>
            <td>{formatPercentage($c, stats['count.editor.votelastweek'] / stats['count.editor.activelastweek'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who edit:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.edits'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.edits'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who vote:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.votes'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.votes'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who leave edit notes:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.notes'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.notes'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use tags:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.tags'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.tags'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use ratings:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.ratings'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.ratings'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use subscriptions:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.subscriptions'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.subscriptions'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use collections:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.active.collections'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.collections'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">
              {l('who have registered applications:')}
            </th>
            <td>{formatCount($c, stats['count.editor.valid.active.applications'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.active.applications'] / stats['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('validated email only:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.validated_only'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.validated_only'] / stats['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('inactive:')}</th>
            <td>{formatCount($c, stats['count.editor.valid.inactive'])}</td>
            <td>{formatPercentage($c, stats['count.editor.valid.inactive'] / stats['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Editors (deleted):')}</th>
            <td>{formatCount($c, stats['count.editor.deleted'])}</td>
            <td />
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Edits')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{formatCount($c, stats['count.edit'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Open:')}</th>
            <td>{formatCount($c, stats['count.edit.open'])}</td>
            <td>{formatPercentage($c, stats['count.edit.open'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Applied:')}</th>
            <td>{formatCount($c, stats['count.edit.applied'])}</td>
            <td>{formatPercentage($c, stats['count.edit.applied'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Voted down:')}</th>
            <td>{formatCount($c, stats['count.edit.failedvote'])}</td>
            <td>{formatPercentage($c, stats['count.edit.failedvote'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (dependency):')}</th>
            <td>{formatCount($c, stats['count.edit.faileddep'])}</td>
            <td>{formatPercentage($c, stats['count.edit.faileddep'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (prerequisite):')}</th>
            <td>{formatCount($c, stats['count.edit.failedprereq'])}</td>
            <td>{formatPercentage($c, stats['count.edit.failedprereq'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (internal error):')}</th>
            <td>{formatCount($c, stats['count.edit.error'])}</td>
            <td>{formatPercentage($c, stats['count.edit.error'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Cancelled:')}</th>
            <td>{formatCount($c, stats['count.edit.deleted'])}</td>
            <td>{formatPercentage($c, stats['count.edit.deleted'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{formatCount($c, stats['count.edit'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{formatCount($c, stats['count.edit.perweek'])}</td>
            <td>{formatPercentage($c, stats['count.edit.perweek'] / stats['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2" />
            <th>{l('Yesterday:')}</th>
            <td>{formatCount($c, stats['count.edit.perday'])}</td>
            <td>{formatPercentage($c, stats['count.edit.perday'] / stats['count.edit.perweek'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Votes')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{formatCount($c, stats['count.vote'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Approve', 'vote'))}</th>
            <td>{formatCount($c, stats['count.vote.approve'])}</td>
            <td>{formatPercentage($c, stats['count.vote.approve'] / stats['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Yes', 'vote'))}</th>
            <td>{formatCount($c, stats['count.vote.yes'])}</td>
            <td>{formatPercentage($c, stats['count.vote.yes'] / stats['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('No', 'vote'))}</th>
            <td>{formatCount($c, stats['count.vote.no'])}</td>
            <td>{formatPercentage($c, stats['count.vote.no'] / stats['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Abstain', 'vote'))}</th>
            <td>{formatCount($c, stats['count.vote.abstain'])}</td>
            <td>{formatPercentage($c, stats['count.vote.abstain'] / stats['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{formatCount($c, stats['count.vote'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{formatCount($c, stats['count.vote.perweek'])}</td>
            <td>{formatPercentage($c, stats['count.vote.perweek'] / stats['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('Yesterday:')}</th>
            <td>{formatCount($c, stats['count.vote.perday'])}</td>
            <td>{formatPercentage($c, stats['count.vote.perday'] / stats['count.vote.perweek'], 1)}</td>
          </tr>
        </tbody>
      </table>
    </StatisticsLayout>
  );
};

export default withCatalystContext(Index);
