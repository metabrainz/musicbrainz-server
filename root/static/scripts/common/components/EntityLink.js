/*
 * @flow strict
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';

import isGreyedOut from '../../url/utility/isGreyedOut.js';
import localizeAreaName from '../i18n/localizeAreaName.js';
import localizeInstrumentName from '../i18n/localizeInstrumentName.js';
import bracketed, {bracketedText} from '../utility/bracketed.js';
import entityHref from '../utility/entityHref.js';
import formatDatePeriod from '../utility/formatDatePeriod.js';
import isolateText from '../utility/isolateText.js';

type DeletedLinkProps = {
  +allowNew: boolean,
  +className?: string,
  +deletedCaption?: string,
  +name: ?Expand2ReactOutput,
};

export const DeletedLink = ({
  allowNew,
  className,
  deletedCaption,
  name,
}: DeletedLinkProps): React.Element<'span'> => {
  const caption = nonEmpty(deletedCaption) ? deletedCaption : (allowNew
    ? l('This entity will be created by this edit.')
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
      {isolateText(nonEmpty(name) ? name : l('[removed]'))}
    </span>
  );
};

const iconClassPicker = {
  area: 'arealink',
  artist: 'artistlink',
  collection: null,
  editor: null,
  event: 'eventlink',
  genre: null,
  instrument: 'instrumentlink',
  label: 'labellink',
  link_type: null,
  place: 'placelink',
  recording: 'recordinglink',
  release: 'releaselink',
  release_group: 'rglink',
  series: 'serieslink',
  url: null,
  work: 'worklink',
};

const Comment = ({
  className,
  comment,
}: {+className: string, +comment: string}) => (
  <>
    {' '}
    <span className={className}>
      {bracketed(<bdi key="comment">{comment}</bdi>)}
    </span>
  </>
);

const EventDisambiguation = ({
  event,
  showDate,
}: {+event: EventT, +showDate: boolean}) => {
  const dates = formatDatePeriod(event);
  if ((!dates || !showDate) && !event.cancelled) {
    return null;
  }
  return (
    <>
      {dates && showDate ? ' ' + bracketedText(dates) : null}
      {event.cancelled
        ? <Comment className="cancelled" comment={l('cancelled')} />
        : null}
    </>
  );
};

const AreaDisambiguation = ({area}: {+area: AreaT}) => {
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
};

const disabledLinkText = N_l(`This link has been temporarily disabled because
                              it has been reported as potentially harmful.`);

const NoInfoURL = ({allowNew, url}: {+allowNew: boolean, +url: string}) => (
  <>
    {isGreyedOut(url) ? (
      <span
        className="deleted"
        title={disabledLinkText()}
      >
        {isolateText(url)}
      </span>
    ) : <a className="url-entity-link" href={url}>{url}</a>}
    {' '}
    <DeletedLink
      allowNew={allowNew}
      name={bracketedText(l('info'), {type: '[]'})}
    />
  </>
);

/* eslint-disable sort-keys, flowtype/sort-keys */
type EntityLinkProps = {
  +allowNew?: boolean,
  +content?: ?Expand2ReactOutput,
  +deletedCaption?: string,
  +disableLink?: boolean,
  +entity: CentralEntityT | CollectionT | LinkTypeT,
  +hover?: string,
  +nameVariation?: boolean,
  +showCaaPresence?: boolean,
  +showDeleted?: boolean,
  +showDisambiguation?: boolean,
  +showEditsPending?: boolean,
  +showEventDate?: boolean,
  +showIcon?: boolean,
  +subPath?: string,

  // ...anchorProps
  className?: string,
  href?: string,
  title?: string,
  +target?: '_blank',
};
/* eslint-enable sort-keys, flowtype/sort-keys */

const EntityLink = ({
  allowNew = false,
  content: passedContent,
  deletedCaption,
  disableLink = false,
  entity,
  hover: passedHover,
  nameVariation: passedNameVariation = false,
  showCaaPresence = false,
  showDeleted = true,
  showDisambiguation: passedShowDisambiguation,
  showEditsPending = true,
  showEventDate = true,
  showIcon: passedShowIcon = false,
  subPath,
  ...anchorProps
}: EntityLinkProps):
$ReadOnlyArray<Expand2ReactOutput> | Expand2ReactOutput | null => {
  const hasCustomContent = nonEmpty(passedContent);
  const hasEditsPending = entity.editsPending || false;
  const hasSubPath = nonEmpty(subPath);
  const comment = nonEmpty(entity.comment) ? ko.unwrap(entity.comment) : '';

  let content = passedContent;
  let hover = passedHover;
  let nameVariation = passedNameVariation;
  let showDisambiguation = passedShowDisambiguation;
  let showIcon = passedShowIcon;

  if (showDisambiguation === undefined) {
    showDisambiguation = !hasCustomContent;
  }

  if (entity.entityType === 'artist' && empty(hover)) {
    hover = entity.sort_name + (comment ? ' ' + bracketedText(comment) : '');
  }

  if (entity.entityType === 'area') {
    content = nonEmpty(content) ? content : localizeAreaName(entity);
  } else if (entity.entityType === 'instrument') {
    content = nonEmpty(content) ? content : localizeInstrumentName(entity);
  } else if (entity.entityType === 'link_type') {
    content = nonEmpty(content) ? content : l_relationships(entity.name);
  }

  content = nonEmpty(content) ? content : ko.unwrap(entity.name);

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
      nameVariation = content !== entity.name;
    }

    if (nameVariation) {
      if (nonEmpty(hover)) {
        hover = texp.l('{name} – {additional_info}', {
          additional_info: hover,
          name: entity.name,
        });
      } else {
        hover = ko.unwrap(entity.name);
      }
    }
  }

  anchorProps.href = href;

  if (nonEmpty(hover)) {
    anchorProps.title = hover;
  }

  if (entity.entityType === 'url') {
    anchorProps.className = 'url-entity-link';
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

  if (nameVariation) {
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

  if (showCaaPresence) {
    if (entity.entityType === 'release' &&
        entity.cover_art_presence === 'present') {
      content = (
        <React.Fragment key="caa">
          <a href={'/release/' + entity.gid + '/cover-art'}>
            <span
              className="caa-icon"
              title={l('This release has artwork in the Cover Art Archive')}
            />
          </a>
          {content}
        </React.Fragment>
      );
    }

    if (entity.entityType === 'release_group' && entity.hasCoverArt) {
      content = (
        <React.Fragment key="caa">
          <span
            className="caa-icon"
            title={l(
              'This release group has artwork in the Cover Art Archive',
            )}
          />
          {content}
        </React.Fragment>
      );
    }
  }

  if (!hasSubPath && entity.entityType === 'release') {
    if (entity.quality === 2) {
      content = (
        <>
          <span
            className="high-data-quality"
            title={l(
              `High quality: All available data has been added, if possible
               including cover art with liner info that proves it`,
            )}
          />
          {content}
        </>
      );
    } else if (entity.quality === 0) {
      content = (
        <React.Fragment key="quality">
          <span
            className="low-data-quality"
            title={l(
              `Low quality: The release needs serious fixes, or its existence
               is hard to prove (but it’s not clearly fake)`,
            )}
          />
          {content}
        </React.Fragment>
      );
    }
  }

  const parts = [content];

  if (showIcon) {
    parts.unshift(
      <span className={iconClassPicker[entity.entityType]} key="icon" />,
    );
  }

  if (!showDisambiguation && empty(infoLink)) {
    return parts;
  }

  if (showDisambiguation) {
    if (entity.entityType === 'event') {
      parts.push(
        <EventDisambiguation
          event={entity}
          key="eventdisambig"
          showDate={showEventDate}
        />,
      );
    }
    if (comment) {
      parts.push(
        <Comment className="comment" comment={comment} key="comment" />,
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

  return React.createElement(React.Fragment, null, ...parts);
};

export default EntityLink;
