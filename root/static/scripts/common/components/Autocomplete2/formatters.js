/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {stripAttributes} from '../../../edit/utility/linkPhrase.js';
import {INSTRUMENT_ROOT_ID} from '../../constants.js';
import {unwrapNl} from '../../i18n.js';
import {addColonText} from '../../i18n/addColon.js';
import {commaOnlyListText} from '../../i18n/commaOnlyList.js';
import localizeLanguageName from '../../i18n/localizeLanguageName.js';
import localizeLinkAttributeTypeDescription
  from '../../i18n/localizeLinkAttributeTypeDescription.js';
import localizeLinkAttributeTypeName
  from '../../i18n/localizeLinkAttributeTypeName.js';
import {reduceArtistCredit} from '../../immutable-entities.js';
import bracketed, {bracketedText} from '../../utility/bracketed.js';
import formatDate from '../../utility/formatDate.js';
import formatDatePeriod from '../../utility/formatDatePeriod.js';
import formatTrackLength from '../../utility/formatTrackLength.js';
import CountryAbbr from '../CountryAbbr.js';

import type {
  EntityItemT,
  ItemT,
} from './types.js';

const nonLatinRegExp = /[^\u0000-\u02ff\u1E00-\u1EFF\u2000-\u207F]/;

function isNonLatin(str: string) {
  return nonLatinRegExp.test(str);
}

function showExtraInfo(
  children: React.Node,
  className?: string = 'comment',
) {
  return (
    <span className={`autocomplete-${className}`}>
      {children}
    </span>
  );
}

function showBracketedTextInfo(comment: ?string) {
  return nonEmpty(comment) ? showExtraInfo(bracketedText(comment)) : null;
}

function showExtraInfoLine(
  children: React.Node,
  className?: string = 'comment',
) {
  return (
    <>
      <br />
      {showExtraInfo(children, className)}
    </>
  );
}

function formatName<+T: EntityItemT>(entity: T) {
  return unwrapNl<string>(entity.name);
}

function formatGeneric(
  entity: | ArtistT
          | EventT
          | GenreT
          | InstrumentT
          | LabelT
          | PlaceT
          | ReleaseT
          | WorkT,
  extraInfo: ?((Array<string>) => void),
) {
  const name = formatName(entity);
  const info = [];

  if (nonEmpty(entity.primaryAlias) && entity.primaryAlias !== name) {
    info.push(entity.primaryAlias);
  }

  if (nonEmpty(entity.comment)) {
    info.push(entity.comment);
  }

  if (extraInfo) {
    extraInfo(info);
  }

  return (
    <>
      {name}
      {info.length ? (
        showExtraInfo(bracketedText(commaOnlyListText(info)))
      ) : null}
    </>
  );
}

function formatArtist(artist: ArtistT) {
  const sortName = artist.sort_name;
  let extraInfo;
  if (
    sortName &&
    sortName !== artist.name &&
    empty(artist.primaryAlias) &&
    isNonLatin(artist.name)
  ) {
    extraInfo = (info: Array<string>) => {
      info.unshift(sortName);
    };
  }
  return formatGeneric(artist, extraInfo);
}

function showLabeledTextList(
  label: string,
  items: $ReadOnlyArray<string>,
  className?: string = 'comment',
) {
  return showExtraInfoLine(
    addColonText(label) + ' ' + commaOnlyListText(items),
    className,
  );
}

function showRelatedEntities(
  label: string,
  entities: ?AppearancesT<string>,
  className?: string = 'comment',
) {
  if (entities && entities.hits > 0) {
    let toRender = entities.results;

    if (entities.hits > toRender.length) {
      toRender = toRender.concat(l('…'));
    }

    return showLabeledTextList(label, toRender, className);
  }
  return null;
}

const getName = (item: {+name: string, ...}) => item.name;

function pushContainmentInfo(area: AreaT, extraInfo: Array<string>) {
  const containment = area.containment;
  if (containment && containment.length) {
    extraInfo.push(...containment.map(getName));
  }
}

function formatArea(area: AreaT) {
  const extraInfo = [];

  if (nonEmpty(area.typeName)) {
    extraInfo.push(lp_attributes(area.typeName, 'area_type'));
  }

  pushContainmentInfo(area, extraInfo);

  return (
    <>
      {area.name}
      {showBracketedTextInfo(area.comment)}
      {showExtraInfoLine(commaOnlyListText(extraInfo))}
    </>
  );
}

function formatEvent(event: EventT) {
  return (
    <>
      {formatGeneric(event)}

      {nonEmpty(event.typeName) ? (
        <>
          {' '}
          {showExtraInfo(
            bracketedText(lp_attributes(event.typeName, 'event_type')),
          )}
        </>
      ) : null}

      {event.begin_date || event.time ? showExtraInfoLine(
        (event.begin_date ? formatDatePeriod(event) + ' ' : '') +
        (event.time || ''),
      ) : null}

      {showRelatedEntities(
        l('Performers'),
        event.related_entities?.performers,
      )}
      {showRelatedEntities(l('Location'), event.related_entities?.places)}
    </>
  );
}

function stripHtml(description: ?string) {
  if (nonEmpty(description)) {
    // We want to strip html from the non-clickable description
    const div = document.createElement('div');
    div.innerHTML = description;
    return div.textContent;
  }
  return description;
}

function formatInstrument(
  instrument: InstrumentT,
  showDescriptions: ?boolean,
) {
  const extraInfo = [];

  if (nonEmpty(instrument.typeName)) {
    extraInfo.push(lp_attributes(instrument.typeName, 'instrument_type'));
  }

  let description;
  if (showDescriptions !== false) {
    description = stripHtml(
      instrument.description
        ? l_instrument_descriptions(instrument.description)
        : null,
    );
  }

  return (
    <>
      {formatGeneric(instrument, (info) => {
        info.push(...extraInfo);
      })}
      {nonEmpty(description) ? showExtraInfoLine(description) : null}
    </>
  );
}

function formatLinkAttributeType(
  type: LinkAttrTypeT,
  showDescriptions: ?boolean,
) {
  if (type.root_id === INSTRUMENT_ROOT_ID) {
    return formatInstrument({
      comment: type.instrument_comment ?? '',
      description: type.description,
      entityType: 'instrument',
      gid: type.gid,
      id: 0,
      last_updated: null,
      name: type.name,
      typeID: type.instrument_type_id ?? null,
      typeName: type.instrument_type_name,
    }, showDescriptions);
  }

  let description;
  if (showDescriptions !== false) {
    description = stripHtml(
      localizeLinkAttributeTypeDescription(type),
    );
  }

  return (
    <>
      {localizeLinkAttributeTypeName(type)}
      {nonEmpty(description) ? showExtraInfoLine(description) : null}
    </>
  );
}

function formatLinkType(
  linkType: LinkTypeT,
  showDescriptions: ?boolean,
) {
  const description = stripHtml(linkType.l_description);
  const isGroupingType = empty(description);

  let nameDisplay = linkType.l_name;
  if (!isGroupingType) {
    let linkPhrase = linkType.l_link_phrase;
    let reverseLinkPhrase = linkType.l_reverse_link_phrase;
    if (!empty(linkPhrase) && !empty(reverseLinkPhrase)) {
      linkPhrase = stripAttributes(linkType, linkPhrase);
      reverseLinkPhrase = stripAttributes(linkType, reverseLinkPhrase);
      if (linkPhrase === reverseLinkPhrase) {
        nameDisplay = linkPhrase;
      } else {
        nameDisplay =
          texp.l('{forward_link_phrase} / {backward_link_phrase}', {
            backward_link_phrase: reverseLinkPhrase,
            forward_link_phrase: linkPhrase,
          });
      }
    }
  }

  return (
    <>
      {nameDisplay}
      {(
        isGroupingType || showDescriptions !== true
      ) ? null : showExtraInfoLine(description)}
    </>
  );
}

function formatPlace(place: PlaceT) {
  const extraInfo = [];

  if (nonEmpty(place.typeName)) {
    extraInfo.push(lp_attributes(place.typeName, 'place_type'));
  }

  const area = place.area;
  if (area) {
    extraInfo.push(area.name);
    pushContainmentInfo(area, extraInfo);
  }

  return (
    <>
      {formatGeneric(place)}
      {showExtraInfoLine(commaOnlyListText(extraInfo))}
    </>
  );
}

function formatRecording(recording: RecordingT) {
  const appearsOn = recording.appearsOn;

  return (
    <>
      {recording.video ? (
        <span className="video" title={l('This recording is a video')} />
      ) : null}

      {recording.name}

      {showBracketedTextInfo(recording.comment)}

      {recording.length ? (
        showExtraInfo(formatTrackLength(recording.length), 'length')
      ) : null}

      {nonEmpty(recording.artist) ? (
        showExtraInfoLine(texp.l('by {artist}', {artist: recording.artist}))
      ) : null}

      {appearsOn ? (
        appearsOn.hits > 0 ? (
          showRelatedEntities(l('appears on'), {
            hits: appearsOn.hits,
            results: appearsOn.results.map(getName),
          }, 'appears')
        ) : showExtraInfoLine(l('standalone recording'), 'appears')
      ) : null}

      {recording.isrcs && recording.isrcs.length ? showLabeledTextList(
        l('ISRCs'),
        recording.isrcs.map(isrc => isrc.isrc),
        'isrcs',
      ) : null}
    </>
  );
}

function formatReleaseEvent(event: ReleaseEventT) {
  const date = formatDate(event.date);
  const country = event.country;
  const countryDisplay = country ? <CountryAbbr country={country} /> : null;

  return (
    <React.Fragment key={(country ? country.id : '') + ',' + date}>
      <br />
      <span className="autocomplete-comment">
        {date}
        {date ? ' ' : ''}
        {date ? bracketed(countryDisplay) : countryDisplay}
      </span>
    </React.Fragment>
  );
}

function formatRelease(release: ReleaseT) {
  const releaseLabels = release.labels;
  const releaseLabelDisplay = [];

  if (releaseLabels) {
    const catNosByLabel = new Map<string, Array<string>>();

    for (const releaseLabel of releaseLabels) {
      const labelName = releaseLabel.label ? releaseLabel.label.name : '';

      let catNos = catNosByLabel.get(labelName);
      if (!catNos) {
        catNos = [];
        catNosByLabel.set(labelName, catNos);
      }

      if (nonEmpty(releaseLabel.catalogNumber)) {
        catNos.push(releaseLabel.catalogNumber);
      }
    }

    for (const [labelName, catNos] of catNosByLabel) {
      catNos.sort();

      const catNoDisplay = catNos.length ? (
        catNos.length > 2 ? (
          texp.l('{first_list_item} … {last_list_item}', {
            first_list_item: catNos[0],
            last_list_item: catNos[catNos.length - 1],
          })
        ) : commaOnlyListText(catNos)
      ) : null;

      releaseLabelDisplay.push(showExtraInfoLine(
        <>
          {labelName}
          {labelName ? ' ' + bracketedText(catNoDisplay) : catNoDisplay}
        </>,
      ));
    }
  }

  return (
    <>
      {formatGeneric(release)}
      {showExtraInfoLine(reduceArtistCredit(release.artistCredit))}
      {release.events ? release.events.map(formatReleaseEvent) : null}
      {releaseLabelDisplay}
      {nonEmpty(release.barcode) ? showExtraInfoLine(release.barcode) : ''}
    </>
  );
}

function formatReleaseGroup(releaseGroup: ReleaseGroupT) {
  return (
    <>
      {releaseGroup.name}

      {showBracketedTextInfo(releaseGroup.firstReleaseDate)}

      {showBracketedTextInfo(releaseGroup.comment)}

      {nonEmpty(releaseGroup.l_type_name) ? (
        showExtraInfoLine(texp.l('{release_group_type} by {artist}', {
          artist: releaseGroup.artist,
          release_group_type: releaseGroup.l_type_name,
        }))
      ) : (
        showExtraInfoLine(texp.l('Release group by {artist}', {
          artist: releaseGroup.artist,
        }))
      )}
    </>
  );
}

function formatSeries(series: SeriesT) {
  return (
    <>
      {series.name}

      {showBracketedTextInfo(series.comment)}

      {series.type ? (
        showExtraInfo(
          bracketedText(lp_attributes(series.type.name, 'series_type')),
        )
      ) : null}
    </>
  );
}

function formatWork(work: WorkT) {
  const languages = work.languages;
  const typeName = work.typeName;

  return (
    <>
      {languages && languages.length ? (
        showExtraInfo(
          commaOnlyListText(
            languages.map(wl => localizeLanguageName(wl.language, true)),
          ),
          'language',
        )
      ) : null}

      {formatGeneric(work)}

      {nonEmpty(typeName) ? (
        showExtraInfoLine(
          addColonText(l('Type')) + ' ' +
          lp_attributes(typeName, 'work_type'),
        )
      ) : null}

      {work.artists ? (
        <>
          {showRelatedEntities(l('Writers'), work.related_artists?.writers)}
          {showRelatedEntities(l('Artists'), work.related_artists?.artists)}
        </>
      ) : null}
    </>
  );
}

export type FormatOptionsT = {
  +showDescriptions?: boolean,
};

export default function formatItem<+T: EntityItemT>(
  item: ItemT<T>,
  options?: ?FormatOptionsT,
): Expand2ReactOutput {
  switch (item.type) {
    case 'action':
    case 'header': {
      return unwrapNl<string>(item.name);
    }
    case 'option': {
      const entity = item.entity;

      switch (entity.entityType) {
        case 'area':
          return formatArea(entity);

        case 'artist':
          return formatArtist(entity);

        case 'event':
          return formatEvent(entity);

        case 'genre':
          return formatGeneric(entity);

        case 'instrument':
          return formatInstrument(
            entity,
            options?.showDescriptions,
          );

        case 'label':
          return formatGeneric(entity);

        case 'link_attribute_type':
          return formatLinkAttributeType(
            entity,
            options?.showDescriptions,
          );

        case 'link_type':
          return formatLinkType(
            entity,
            options?.showDescriptions,
          );

        case 'place':
          return formatPlace(entity);

        case 'recording':
          return formatRecording(entity);

        case 'release':
          return formatRelease(entity);

        case 'release_group':
          return formatReleaseGroup(entity);

        case 'series':
          return formatSeries(entity);

        case 'work':
          return formatWork(entity);

        default:
          return unwrapNl<string>(item.name);
      }
    }
  }
  return '';
}
