/*
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const Layout = require('./Layout');
const manifest = require('../static/manifest');
const {addColon, formatCount, formatPercentage} = require('./utilities');
const {l, ln, lp} = require('../static/scripts/common/i18n');

const Index = () => {
  const stats = $c.stash.stats;
  const oneToNine = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  return (
    <Layout fullWidth page="index" title={l('Overview')}>
      {manifest.css('statistics')}
      <p>{l('Last updated: {date}',
        {__react: true, date: stats.date_collected})}
      </p>
      <h2>{l('Basic metadata')}</h2>
      <table className="database-statistics">
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Core Entities')}</th>
          </tr>
          <tr>
            <th>{l('Artists:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.artist'])}</td>
          </tr>
          <tr>
            <th>{l('Release Groups:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.releasegroup'])}</td>
          </tr>
          <tr>
            <th>{l('Releases:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.release'])}</td>
          </tr>
          <tr>
            <th>{l('Mediums:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.medium'])}</td>
          </tr>
          <tr>
            <th>{l('Recordings:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.recording'])}</td>
          </tr>
          <tr>
            <th>{l('Tracks:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.track'])}</td>
          </tr>
          <tr>
            <th>{l('Labels:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.label'])}</td>
          </tr>
          <tr>
            <th>{l('Works:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.work'])}</td>
          </tr>
          <tr>
            <th>{l('URLs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.url'])}</td>
          </tr>
          <tr>
            <th>{l('Areas:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.area'])}</td>
          </tr>
          <tr>
            <th>{l('Places:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.place'])}</td>
          </tr>
          <tr>
            <th>{lp('Series:', 'plural')}</th>
            <td colSpan="3">{formatCount(stats.data['count.series'])}</td>
          </tr>
          <tr>
            <th>{l('Instruments:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.instrument'])}</td>
          </tr>
          <tr>
            <th>{l('Events:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.event'])}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Other Entities')}</th>
          </tr>
          <tr>
            <th>{l('Editors (valid / deleted):')}</th>
            <td>{formatCount(stats.data['count.editor.valid'])}</td>
            <td>{'/'}</td>
            <td>{formatCount(stats.data['count.editor.deleted'])}</td>
          </tr>
          <tr>
            <th>{l('Relationships:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.ar.links'])}</td>
          </tr>
          <tr>
            <th>{l('CD Stubs (all time / current):')}</th>
            <td>{formatCount(stats.data['count.cdstub.submitted'])}</td><td>{'/'}</td><td> {formatCount(stats.data['count.cdstub'])}</td>
          </tr>
          <tr>
            <th>{l('Tags (raw / aggregated):')}</th>
            <td>
              {formatCount(stats.data['count.tag.raw'])}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount(stats.data['count.tag'])}
            </td>
          </tr>
          <tr>
            <th>{l('Ratings (raw / aggregated):')}</th>
            <td>
              {formatCount(stats.data['count.rating.raw'])}
            </td>
            <td>{'/'}</td>
            <td>
              {formatCount(stats.data['count.rating'])}
            </td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="4">{l('Identifiers')}</th>
          </tr>
          <tr>
            <th>{l('MBIDs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.mbid'])}</td>
          </tr>
          <tr>
            <th>{l('ISRCs (all / unique):')}</th>
            <td>{formatCount(stats.data['count.isrc.all'])}</td><td>{'/'}</td><td>{formatCount(stats.data['count.isrc'])}</td>
          </tr>
          <tr>
            <th>{l('ISWCs (all / unique):')}</th>
            <td>{formatCount(stats.data['count.iswc.all'])}</td><td>{'/'}</td><td>{formatCount(stats.data['count.iswc'])}</td>
          </tr>
          <tr>
            <th>{l('Disc IDs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.discid'])}</td>
          </tr>
          <tr>
            <th>{l('Barcodes:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.barcode'])}</td>
          </tr>
          <tr>
            <th>{l('IPIs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.ipi'])}</td>
          </tr>
          <tr>
            <th>{l('ISNIs:')}</th>
            <td colSpan="3">{formatCount(stats.data['count.isni'])}</td>
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
            <td>{formatCount(stats.data['count.artist'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('of type Person:')}</th>
            <td>{formatCount(stats.data['count.artist.type.person'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.person'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Group:')}</th>
            <td>{formatCount(stats.data['count.artist.type.group'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.group'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Orchestra:')}</th>
            <td>{formatCount(stats.data['count.artist.type.orchestra'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.orchestra'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Choir:')}</th>
            <td>{formatCount(stats.data['count.artist.type.choir'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.choir'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Character:')}</th>
            <td>{formatCount(stats.data['count.artist.type.character'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.character'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('of type Other:')}</th>
            <td>{formatCount(stats.data['count.artist.type.other'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.other'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no type set:')}</th>
            <td>{formatCount(stats.data['count.artist.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.artist.type.null'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with appearances in artist credits:')}</th>
            <td>{formatCount(stats.data['count.artist.has_credits'])}</td>
            <td>{formatPercentage(stats.data['count.artist.has_credits'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no appearances in artist credits:')}</th>
            <td>{formatCount(stats.data['count.artist.0credits'])}</td>
            <td>{formatPercentage(stats.data['count.artist.0credits'] / stats.data['count.artist'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="2">{l('Non-group artists:')}</th>
            <td>{formatCount(stats.data['count.artist.type.null'] + stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th>{l('Male:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.male'])}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.male'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('Female:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.female'])}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.female'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('Other gender:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.other'])}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.other'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1)}</td>
          </tr>
          <tr>
            <th />
            <th>{l('with no gender set:')}</th>
            <td>{formatCount(stats.data['count.artist.gender.null'])}</td>
            <td>{formatPercentage(stats.data['count.artist.gender.null'] / (stats.data['count.artist.type.person'] + stats.data['count.artist.type.other'] + stats.data['count.artist.type.null']), 1)}</td>
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
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by various artists:')}</th>
            <td>{formatCount(stats.data['count.release.various'])}</td>
            <td>{formatPercentage(stats.data['count.release.various'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('by a single artist:')}</th>
            <td>{formatCount(stats.data['count.release.nonvarious'])}</td>
            <td>{formatPercentage(stats.data['count.release.nonvarious'] / stats.data['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Status')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          {Object.values($c.stash.statuses).map(status => (
            <tr key={status.gid}>
              <th />
              <th colSpan="2">{l(status.name)}</th>
              <td>{formatCount(stats.data['count.release.status.' + status.id])}</td>
              <td>{formatPercentage(stats.data['count.release.status.' + status.id] / stats.data['count.release'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No status set')}</th>
            <td>{formatCount(stats.data['count.release.status.null'])}</td>
            <td>{formatPercentage(stats.data['count.release.status.null'] / stats.data['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Release Packaging')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          {Object.values($c.stash.packagings).map(packaging => (
            <tr key={packaging.gid}>
              <th />
              <th colSpan="2">{l(packaging.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.release.packaging.' + packaging.id])}</td>
              <td>{formatPercentage(stats.data['count.release.packaging.' + packaging.id] / stats.data['count.release'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th colSpan="2">{l('No packaging set')}</th>
            <td>{formatCount(stats.data['count.release.packaging.null'])}</td>
            <td>{formatPercentage(stats.data['count.release.packaging.null'] / stats.data['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Cover Art Sources')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('CAA:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.caa'])}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.caa'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Amazon:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.amazon'])}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.amazon'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('URL Relationships:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.relationship'])}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.relationship'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('No front cover art:')}</th>
            <td>{formatCount(stats.data['count.release.coverart.none'])}</td>
            <td>{formatPercentage(stats.data['count.release.coverart.none'] / stats.data['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Data Quality')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('High Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.high'])}</td>
            <td>{formatPercentage(stats.data['count.quality.release.high'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Default Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.default'])}</td>
            <td>{formatPercentage(stats.data['count.quality.release.default'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Normal Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.normal'])}</td>
            <td>{formatPercentage(stats.data['count.quality.release.normal'] / stats.data['count.quality.release.default'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th>{l('Unknown Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.unknown'])}</td>
            <td>{formatPercentage(stats.data['count.quality.release.unknown'] / stats.data['count.quality.release.default'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Low Data Quality:')}</th>
            <td>{formatCount(stats.data['count.quality.release.low'])}</td>
            <td>{formatPercentage(stats.data['count.quality.release.low'] / stats.data['count.release'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="5">{l('Disc IDs')}</th>
          </tr>
          <tr>
            <th colSpan="3">{l('Disc IDs:')}</th>
            <td>{formatCount(stats.data['count.discid'])}</td>
            <td />
          </tr>
          <tr>
            <th colSpan="3">{l('Releases:')}</th>
            <td>{formatCount(stats.data['count.release'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Releases with no disc IDs:')}</th>
            <td>{formatCount(stats.data['count.release.0discids'])}</td>
            <td>{formatPercentage(stats.data['count.release.0discids'] / stats.data['count.release'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Releases with at least one disc ID:')}</th>
            <td>{formatCount(stats.data['count.release.has_discid'])}</td>
            <td>{formatPercentage(stats.data['count.release.has_discid'] / stats.data['count.release'], 1)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{ln('with {num} disc ID:', 'with {num} disc IDs:', num, {__react: true, num: num})}</th>
              <td>{formatCount(stats.data['count.release.' + num + 'discids'])}</td>
              <td>{formatPercentage(stats.data['count.release.' + num + 'discids'] / stats.data['count.release.has_discid'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{formatCount(stats.data['count.release.10discids'])}</td>
            <td>{formatPercentage(stats.data['count.release.10discids'] / stats.data['count.release.has_discid'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="3">{l('Mediums:')}</th>
            <td>{formatCount(stats.data['count.medium'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Mediums with no disc IDs:')}</th>
            <td>{formatCount(stats.data['count.medium.0discids'])}</td>
            <td>{formatPercentage(stats.data['count.medium.0discids'] / stats.data['count.medium'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2">{l('Mediums with at least one disc ID:')}</th>
            <td>{formatCount(stats.data['count.medium.has_discid'])}</td>
            <td>{formatPercentage(stats.data['count.medium.has_discid'] / stats.data['count.medium'], 1)}</td>
          </tr>
          {oneToNine.map(num => (
            <tr key={num}>
              <th />
              <th />
              <th>{ln('with {num} disc ID:', 'with {num} disc IDs:', num, {__react: true, num: num})}</th>
              <td>{formatCount(stats.data['count.medium.' + num + 'discids'])}</td>
              <td>{formatPercentage(stats.data['count.medium.' + num + 'discids'] / stats.data['count.medium.has_discid'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th />
            <th>{l('with 10 or more disc IDs:')}</th>
            <td>{formatCount(stats.data['count.medium.10discids'])}</td>
            <td>{formatPercentage(stats.data['count.medium.10discids'] / stats.data['count.medium.has_discid'], 1)}</td>
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
            <td>{formatCount(stats.data['count.releasegroup'])}</td>
            <td />
          </tr>
          {Object.values($c.stash.primary_types).map(primaryType => (
            <tr key={primaryType.gid}>
              <th />
              <th>{l(primaryType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.releasegroup.primary_type.' + primaryType.id])}</td>
              <td>{formatPercentage(stats.data['count.releasegroup.primary_type.' + primaryType.id] / stats.data['count.releasegroup'], 1)}</td>
            </tr>
          ))}
          <tr className="thead">
            <th colSpan="4">{l('Secondary Types')}</th>
          </tr>
          <tr>
            <th colSpan="2">{l('Release Groups:')}</th>
            <td>{formatCount(stats.data['count.releasegroup'])}</td>
            <td />
          </tr>
          {Object.values($c.stash.secondary_types).map(secondaryType => (
            <tr key={secondaryType.gid}>
              <th />
              <th>{l(secondaryType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.releasegroup.secondary_type.' + secondaryType.id])}</td>
              <td>{formatPercentage(stats.data['count.releasegroup.secondary_type.' + secondaryType.id] / stats.data['count.releasegroup'], 1)}</td>
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
            <td>{formatCount(stats.data['count.recording'])}</td>
            <td />
          </tr>
          <tr>
            <th>{l('Videos:')}</th>
            <td>{formatCount(stats.data['count.video'])}</td>
            <td>{formatPercentage(stats.data['count.video'] / stats.data['count.recording'], 1)}</td>
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
            <td>{formatCount(stats.data['count.label'])}</td>
            <td />
          </tr>
          {$c.stash.label_types.map(labelType => (
            <tr key={labelType.gid}>
              <th />
              <th>{l(labelType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.label.type.' + labelType.id])}</td>
              <td>{formatPercentage(stats.data['count.label.type.' + labelType.id] / stats.data['count.label'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.label.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.label.type.null'] / stats.data['count.label'], 1)}</td>
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
            <td>{formatCount(stats.data['count.work'])}</td>
            <td />
          </tr>
          {$c.stash.work_types.map(workType => (
            <tr key={workType.gid}>
              <th />
              <th>{l(workType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.work.type.' + workType.id])}</td>
              <td>{formatPercentage(stats.data['count.work.type.' + workType.id] / stats.data['count.work'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.work.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.work.type.null'] / stats.data['count.work'], 1)}</td>
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
            <td>{formatCount(stats.data['count.work'])}</td>
            <td />
          </tr>
          {$c.stash.work_attribute_types.map(workAttributeType => (
            <tr key={workAttributeType.gid}>
              <th />
              <th>{l(workAttributeType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.work.attribute.' + workAttributeType.id])}</td>
              <td>{formatPercentage(stats.data['count.work.attribute.' + workAttributeType.id] / stats.data['count.work'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.work.attribute.null'])}</td>
            <td>{formatPercentage(stats.data['count.work.attribute.null'] / stats.data['count.work'], 1)}</td>
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
            <td>{formatCount(stats.data['count.area'])}</td>
            <td />
          </tr>
          {$c.stash.area_types.map(areaType => (
            <tr key={areaType.gid}>
              <th />
              <th>{l(areaType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.area.type.' + areaType.id])}</td>
              <td>{formatPercentage(stats.data['count.area.type.' + areaType.id] / stats.data['count.area'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.area.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.area.type.null'] / stats.data['count.area'], 1)}</td>
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
            <td>{formatCount(stats.data['count.place'])}</td>
            <td />
          </tr>
          {$c.stash.place_types.map(placeType => (
            <tr key={placeType.gid}>
              <th />
              <th>{l(placeType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.place.type.' + placeType.id])}</td>
              <td>{formatPercentage(stats.data['count.place.type.' + placeType.id] / stats.data['count.place'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.place.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.place.type.null'] / stats.data['count.place'], 1)}</td>
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
            <td>{formatCount(stats.data['count.series'])}</td>
            <td />
          </tr>
          {$c.stash.series_types.map(seriesType => (
            <tr key={seriesType.gid}>
              <th />
              <th>{l(seriesType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.series.type.' + seriesType.id])}</td>
              <td>{formatPercentage(stats.data['count.series.type.' + seriesType.id] / stats.data['count.series'], 1)}</td>
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
            <td>{formatCount(stats.data['count.instrument'])}</td>
            <td />
          </tr>
          {$c.stash.instrument_types.map(instrumentType => (
            <tr key={instrumentType.gid}>
              <th />
              <th>{l(instrumentType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.instrument.type.' + instrument_type.id])}</td>
              <td>{formatPercentage(stats.data['count.instrument.type.' + instrument_type.id] / stats.data['count.instrument'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.instrument.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.instrument.type.null'] / stats.data['count.instrument'], 1)}</td>
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
            <td>{formatCount(stats.data['count.event'])}</td>
            <td />
          </tr>
          {$c.stash.event_types.map(eventType => (
            <tr key={eventType.gid}>
              <th />
              <th>{l(eventType.name, {__react: true})}</th>
              <td>{formatCount(stats.data['count.event.type.' + eventType.id])}</td>
              <td>{formatPercentage(stats.data['count.event.type.' + eventType.id] / stats.data['count.event'], 1)}</td>
            </tr>
          ))}
          <tr>
            <th />
            <th>{l('None')}</th>
            <td>{formatCount(stats.data['count.event.type.null'])}</td>
            <td>{formatPercentage(stats.data['count.event.type.null'] / stats.data['count.event'], 1)}</td>
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
            <td>{formatCount(stats.data['count.editor.valid'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('active ever:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active'] / stats.data['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who edited and/or voted in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.activelastweek'])}</td>
            <td>{formatPercentage(stats.data['count.editor.activelastweek'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who edited in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.editlastweek'])}</td>
            <td>{formatPercentage(stats.data['count.editor.editlastweek'] / stats.data['count.editor.activelastweek'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th />
            <th>{l('who voted in the last 7 days:')}</th>
            <td>{formatCount(stats.data['count.editor.votelastweek'])}</td>
            <td>{formatPercentage(stats.data['count.editor.votelastweek'] / stats.data['count.editor.activelastweek'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who edit:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.edits'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.edits'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who vote:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.votes'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.votes'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who leave edit notes:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.notes'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.notes'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use tags:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.tags'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.tags'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use ratings:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.ratings'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.ratings'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use subscriptions:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.subscriptions'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.subscriptions'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who use collections:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.collections'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.collections'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('who have registered applications:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.active.applications'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.active.applications'] / stats.data['count.editor.valid.active'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('validated email only:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.validated_only'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.validated_only'] / stats.data['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('inactive:')}</th>
            <td>{formatCount(stats.data['count.editor.valid.inactive'])}</td>
            <td>{formatPercentage(stats.data['count.editor.valid.inactive'] / stats.data['count.editor.valid'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Editors (deleted):')}</th>
            <td>{formatCount(stats.data['count.editor.deleted'])}</td>
            <td />
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Edits')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{formatCount(stats.data['count.edit'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Open:')}</th>
            <td>{formatCount(stats.data['count.edit.open'])}</td>
            <td>{formatPercentage(stats.data['count.edit.open'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Applied:')}</th>
            <td>{formatCount(stats.data['count.edit.applied'])}</td>
            <td>{formatPercentage(stats.data['count.edit.applied'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Voted down:')}</th>
            <td>{formatCount(stats.data['count.edit.failedvote'])}</td>
            <td>{formatPercentage(stats.data['count.edit.failedvote'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (dependency):')}</th>
            <td>{formatCount(stats.data['count.edit.faileddep'])}</td>
            <td>{formatPercentage(stats.data['count.edit.faileddep'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (prerequisite):')}</th>
            <td>{formatCount(stats.data['count.edit.failedprereq'])}</td>
            <td>{formatPercentage(stats.data['count.edit.failedprereq'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Failed (internal error):')}</th>
            <td>{formatCount(stats.data['count.edit.error'])}</td>
            <td>{formatPercentage(stats.data['count.edit.error'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Cancelled:')}</th>
            <td>{formatCount(stats.data['count.edit.deleted'])}</td>
            <td>{formatPercentage(stats.data['count.edit.deleted'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Edits:')}</th>
            <td>{formatCount(stats.data['count.edit'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{formatCount(stats.data['count.edit.perweek'])}</td>
            <td>{formatPercentage(stats.data['count.edit.perweek'] / stats.data['count.edit'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="2" />
            <th>{l('Yesterday:')}</th>
            <td>{formatCount(stats.data['count.edit.perday'])}</td>
            <td>{formatPercentage(stats.data['count.edit.perday'] / stats.data['count.edit.perweek'], 1)}</td>
          </tr>
        </tbody>
        <tbody>
          <tr className="thead">
            <th colSpan="6">{l('Votes')}</th>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{formatCount(stats.data['count.vote'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Approve', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.approve'])}</td>
            <td>{formatPercentage(stats.data['count.vote.approve'] / stats.data['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Yes', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.yes'])}</td>
            <td>{formatPercentage(stats.data['count.vote.yes'] / stats.data['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('No', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.no'])}</td>
            <td>{formatPercentage(stats.data['count.vote.no'] / stats.data['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th colSpan="3">{addColon(lp('Abstain', 'vote'))}</th>
            <td>{formatCount(stats.data['count.vote.abstain'])}</td>
            <td>{formatPercentage(stats.data['count.vote.abstain'] / stats.data['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th colSpan="4">{l('Votes:')}</th>
            <td>{formatCount(stats.data['count.vote'])}</td>
            <td />
          </tr>
          <tr>
            <th />
            <th colSpan="3">{l('Last 7 days:')}</th>
            <td>{formatCount(stats.data['count.vote.perweek'])}</td>
            <td>{formatPercentage(stats.data['count.vote.perweek'] / stats.data['count.vote'], 1)}</td>
          </tr>
          <tr>
            <th />
            <th />
            <th colSpan="2">{l('Yesterday:')}</th>
            <td>{formatCount(stats.data['count.vote.perday'])}</td>
            <td>{formatPercentage(stats.data['count.vote.perday'] / stats.data['count.vote.perweek'], 1)}</td>
          </tr>
        </tbody>
      </table>
    </Layout>
  );
};

module.exports = Index;
