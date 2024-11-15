/*
 * @flow strict
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';
import ko from 'knockout';
import * as React from 'react';

import type {ReleaseEditorTrackT} from '../../release-editor/types.js';
import isGreyedOut from '../../url/utility/isGreyedOut.js';
import commaOnlyList from '../i18n/commaOnlyList.js';
import localizeAreaName from '../i18n/localizeAreaName.js';
import localizeInstrumentName from '../i18n/localizeInstrumentName.js';
import bracketed, {bracketedText} from '../utility/bracketed.js';
import entityHref from '../utility/entityHref.js';
import formatDatePeriod from '../utility/formatDatePeriod.js';
import isolateText from '../utility/isolateText.js';

export component DeletedLink(
  allowNew: boolean,
  className?: string,
  deletedCaption?: string,
  name: ?Expand2ReactOutput,
) {
  const caption = nonEmpty(deletedCaption) ? deletedCaption : (allowNew
    ? l('This entity will be added by this edit.')
    : l('This entity has been removed, and cannot be displayed correctly.'));

  return (
    <span
      className={
        (nonEmpty(className) ? className + ' ' : '') +
        (allowNew ? '' : 'deleted ') +
        'tooltip'
      }
      title={caption}
    >
      {isolateText(nonEmpty(name)
        ? name
        : lp('[removed]', 'generic entity'))}
    </span>
  );
}

const iconClassPicker = {
  area: 'arealink',
  artist: 'artistlink',
  collection: 'collectionlink',
  editor: null,
  event: 'eventlink',
  genre: 'genrelink',
  instrument: 'instrumentlink',
  label: 'labellink',
  link_type: null,
  place: 'placelink',
  recording: 'recordinglink',
  release: 'releaselink',
  release_group: 'rglink',
  series: 'serieslink',
  track: null,
  url: null,
  work: 'worklink',
};

component Comment(
  alias?: string,
  className: string,
  comment: string,
) {
  const aliasElement = nonEmpty(alias)
    ? <i key="primary-alias" title={l('Primary alias')}>{alias}</i>
    : null;
  return (
    <>
      {' '}
      <span className={className}>
        {bracketed(
          <bdi key="comment">
            {nonEmpty(aliasElement) ? (
              nonEmpty(comment) ? (
                commaOnlyList([aliasElement, comment])
              ) : aliasElement
            ) : comment}
          </bdi>,
        )}
      </span>
    </>
  );
}

component EventDisambiguation(event: EventT, showDate: boolean) {
  const dates = formatDatePeriod(event);
  if ((!dates || !showDate) && !event.cancelled) {
    return null;
  }
  return (
    <>
      {dates && showDate ? ' ' + bracketedText(dates) : null}
      {event.cancelled
        ? <Comment className="cancelled" comment={lp('cancelled', 'event')} />
        : null}
    </>
  );
}

component AreaDisambiguation(area: AreaT) {
  if (!area.ended) {
    return null;
  }

  let comment;
  const beginYear = area.begin_date ? area.begin_date.year : null;
  const endYear = area.end_date ? area.end_date.year : null;

  if (beginYear != null && endYear != null) {
    comment = texp.l(
      'historical, {begin}-{end}',
      {begin: beginYear, end: endYear},
    );
  } else if (endYear == null) {
    comment = l('historical');
  } else {
    comment = texp.l('historical, until {end}', {end: endYear});
  }

  return <Comment className="historical" comment={comment} />;
}

const disabledLinkText = N_l(`This link has been temporarily disabled because
                              it has been reported as potentially harmful.`);

component NoInfoURL(allowNew: boolean, url: string) {
  return (
    <>
      {isGreyedOut(url) ? (
        <span
          className="deleted"
          title={disabledLinkText()}
        >
          {isolateText(url)}
        </span>
      ) : <a className="wrap-anywhere" href={url}>{url}</a>}
      {' '}
      <DeletedLink
        allowNew={allowNew}
        name={bracketedText(l('info'), {type: '[]'})}
      />
    </>
  );
}

component EntityLink(
  allowNew: boolean = false,
  content as passedContent?: ?Expand2ReactOutput,
  deletedCaption?: string,
  disableLink: boolean = false,
  entity:
    | RelatableEntityT
    | CollectionT
    | LinkTypeT
    | TrackT
    | ReleaseEditorTrackT,
  nameVariation as passedNameVariation?: boolean,
  showArtworkPresence: boolean = false,
  showCreditedAs: boolean = false,
  showDeleted: boolean = true,
  showDisambiguation as passedShowDisambiguation?: boolean | 'hover',
  showEditsPending: boolean = true,
  showEventDate: boolean = true,
  showIcon as passedShowIcon?: boolean = false,
  subPath?: string,
  ...passedAnchorProps: {
    className?: string,
    href?: string,
    +target?: '_blank',
    title?: string,
  }
) {
  const hasCustomContent = nonEmpty(passedContent);
  // $FlowIgnore[sketchy-null-mixed]
  const hasEditsPending = entity.editsPending || false;
  const hasSubPath = nonEmpty(subPath);
  // $FlowIgnore[prop-missing]
  const comment = nonEmpty(entity.comment) ? ko.unwrap(entity.comment) : '';
  const entityName = ko.unwrap(entity.name);
  const primaryAlias = (entity.entityType !== 'instrument' &&
                        entity.entityType !== 'track' &&
                        nonEmpty(entity.primaryAlias) &&
                        entity.primaryAlias !== entityName)
    ? entity.primaryAlias
    : '';


  let content = passedContent;
  let hover = '';
  let nameVariation = passedNameVariation;
  let showDisambiguation = passedShowDisambiguation;
  let showIcon = passedShowIcon;
  const anchorProps = {...passedAnchorProps};

  if (nameVariation === undefined &&
    nonEmpty(content) && typeof content !== 'string'
  ) {
    const errorMessage = 'Content of type ' + typeof content +
      ' cannot be compared as a string to entity name for name variation.';
    if (__DEV__) {
      invariant(false, errorMessage);
    }
    Sentry.captureException(new Error(errorMessage));
  }

  if (showDisambiguation === undefined) {
    showDisambiguation = !hasCustomContent;
  }

  if (showDisambiguation === 'hover' || entity.entityType === 'artist') {
    const sortName = entity.entityType === 'artist' ? entity.sort_name : '';
    const additionalName = nonEmpty(primaryAlias) ? primaryAlias : sortName;
    hover = nonEmpty(additionalName) ? (
      nonEmpty(comment) ? (
        additionalName + ' ' + bracketedText(comment)
      ) : additionalName
    ) : comment;
  }

  /*
   * If we were asked to display the credited-as text explicitly,
   * display the entity name as the content instead.
   */
  let creditedAs = null;
  if (showCreditedAs && typeof content === 'string' && nonEmpty(content)) {
    creditedAs = content;
    content = undefined;
  }

  if (entity.entityType === 'area') {
    content = empty(content) ? localizeAreaName(entity) : content;
  } else if (entity.entityType === 'instrument') {
    content = empty(content) ? localizeInstrumentName(entity) : content;
  } else if (entity.entityType === 'link_type') {
    content = empty(content) ? l_relationships(entityName) : content;
  }

  content = empty(content) ? entityName : content;

  if (!ko.unwrap(entity.gid)) {
    if (entity.entityType === 'url') {
      return <NoInfoURL allowNew={allowNew} url={entity.href_url} />;
    }
    if (showDeleted) {
      return (
        <DeletedLink
          allowNew={allowNew}
          deletedCaption={deletedCaption}
          name={content}
        />
      );
    }
    return null;
  }

  let href = entityHref(entity, subPath);
  let infoLink;

  if (entity.entityType === 'url' && !hasCustomContent) {
    content = entity.pretty_name;
    infoLink = href;
    href = entity.href_url;
  }

  // URLs are kind of weird and we probably don't care to set this for them
  if (!hasSubPath && entity.entityType !== 'url') {
    if (nameVariation === undefined && typeof content === 'string') {
      nameVariation = content !== entityName;
    }

    if (nameVariation === true) {
      if (nonEmpty(hover)) {
        hover = texp.l('{name} – {additional_info}', {
          additional_info: hover,
          name: entityName,
        });
      } else {
        hover = entityName;
      }
    }
  }

  anchorProps.href = href;

  if (nonEmpty(hover)) {
    anchorProps.title = hover;
  }

  if (entity.entityType === 'url') {
    anchorProps.className = 'wrap-anywhere';
  }

  content = disableLink
    ? (
      <span
        className="deleted"
        key="deleted"
        title={entity.entityType === 'url' && isGreyedOut(href)
          ? disabledLinkText()
          : null}
      >
        {isolateText(content)}
      </span>
    ) : <a key="link" {...anchorProps}>{isolateText(content)}</a>;

  if (nameVariation === true) {
    content = (
      <span className="name-variation" key="namevar">
        {content}
      </span>
    );
  }

  if (showEditsPending && !hasSubPath && hasEditsPending) {
    content = <span className="mp" key="mp">{content}</span>;
  }

  if (!hasSubPath && entity.entityType === 'area') {
    const isoCodes = entity.iso_3166_1_codes;
    if (isoCodes && isoCodes.length) {
      content = (
        <span className={'flag flag-' + isoCodes[0]} key="flag">
          {content}
        </span>
      );
      // Avoid having the icon *and* the flag
      showIcon = false;
    }
  }

  if (!hasSubPath && entity.entityType === 'recording' && entity.video) {
    content = (
      <React.Fragment key="video">
        <span className="video" title={l('This recording is a video')} />
        {content}
      </React.Fragment>
    );
  }

  if (showArtworkPresence) {
    if (entity.entityType === 'event') {
      if (entity.event_art_presence === 'present') {
        content = (
          <React.Fragment key="eaa">
            <a href={'/event/' + entity.gid + '/event-art'}>
              <span
                className="artwork-icon eaa-icon"
                title={l('This event has artwork in the Event Art Archive')}
              />
            </a>
            {content}
          </React.Fragment>
        );
      } else {
        content = (
          <React.Fragment key="caa">
            <span
              className="blank-icon"
            />
            {content}
          </React.Fragment>
        );
      }
    }

    if (entity.entityType === 'release') {
      if (entity.cover_art_presence === 'present') {
        content = (
          <React.Fragment key="caa">
            <a href={'/release/' + entity.gid + '/cover-art'}>
              <span
                className="artwork-icon caa-icon"
                title={l('This release has artwork in the Cover Art Archive')}
              />
            </a>
            {content}
          </React.Fragment>
        );
      } else {
        content = (
          <React.Fragment key="caa">
            <span
              className="blank-icon"
            />
            {content}
          </React.Fragment>
        );
      }
    }

    if (entity.entityType === 'release_group') {
      if (entity.hasCoverArt) {
        content = (
          <React.Fragment key="caa">
            <span
              className="artwork-icon caa-icon"
              title={l(
                'This release group has artwork in the Cover Art Archive',
              )}
            />
            {content}
          </React.Fragment>
        );
      } else {
        content = (
          <React.Fragment key="caa">
            <span
              className="blank-icon"
            />
            {content}
          </React.Fragment>
        );
      }
    }
  }


  if (!hasSubPath && entity.entityType === 'release') {
    if (entity.quality === 2) {
      content = (
        <React.Fragment key="quality">
          {content}
          <span
            className="high-data-quality"
            title={l(
              `High quality: All available data has been added, if possible
               including cover art with liner info that proves it`,
            )}
          />
        </React.Fragment>
      );
    } else if (entity.quality === 0) {
      content = (
        <React.Fragment key="quality">
          {content}
          <span
            className="low-data-quality"
            title={l(
              `Low quality: The release needs serious fixes, or its existence
               is hard to prove (but it’s not clearly fake)`,
            )}
          />
        </React.Fragment>
      );
    }
  }

  const parts: Array<Expand2ReactOutput> = [content];

  if (showIcon) {
    parts.unshift(
      <span className={iconClassPicker[entity.entityType]} key="icon" />,
    );
  }

  if (nonEmpty(creditedAs)) {
    parts.push(
      ' ',
      bracketed(
        <span>{texp.l('as “{credit}”', {credit: creditedAs})}</span>,
      ),
    );
  }

  if (!showDisambiguation && empty(infoLink)) {
    return parts;
  }

  if (showDisambiguation === true) {
    if (entity.entityType === 'event') {
      parts.push(
        <EventDisambiguation
          event={entity}
          key="eventdisambig"
          showDate={showEventDate}
        />,
      );
    }
    if (nonEmpty(comment) || nonEmpty(primaryAlias)) {
      parts.push(
        <Comment
          alias={primaryAlias}
          className="comment"
          comment={comment}
          key="comment"
        />,
      );
    }
    if (entity.entityType === 'area') {
      parts.push(<AreaDisambiguation area={entity} key="areadisambig" />);
    }
  }

  if (nonEmpty(infoLink)) {
    parts.push(
      ' ',
      bracketed(
        <a href={infoLink} key="info">{l('info')}</a>,
        {type: '[]'},
      ),
    );
  }

  return parts;
}

export default EntityLink;
