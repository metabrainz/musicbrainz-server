/*
 * @flow
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';

import localizeAreaName from '../i18n/localizeAreaName';
import localizeInstrumentName from '../i18n/localizeInstrumentName';
import bracketed, {bracketedText} from '../utility/bracketed';
import entityHref from '../utility/entityHref';
import formatDatePeriod from '../utility/formatDatePeriod';
import isolateText from '../utility/isolateText';
import isGreyedOut from '../../../../url/utility/isGreyedOut';

type DeletedLinkProps = {
  +allowNew: boolean,
  +deletedCaption?: string,
  +name: ?Expand2ReactOutput,
};

export const DeletedLink = ({
  allowNew,
  deletedCaption,
  name,
}: DeletedLinkProps): React.Element<'span'> => {
  const caption = deletedCaption || (allowNew
    ? l('This entity will be created by this edit.')
    : l('This entity has been removed, and cannot be displayed correctly.'));

  return (
    <span
      className={(allowNew ? '' : 'deleted ') + 'tooltip'}
      title={caption}
    >
      {isolateText(name || l('[removed]'))}
    </span>
  );
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

  if (beginYear && endYear) {
    comment = texp.l(
      'historical, {begin}-{end}',
      {begin: beginYear, end: endYear},
    );
  } else if (endYear) {
    comment = texp.l('historical, until {end}', {end: endYear});
  } else {
    comment = l('historical');
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
    ) : <a href={url}>{url}</a>}
    {' '}
    <DeletedLink
      allowNew={allowNew}
      name={bracketed(l('info'), {type: '[]'})}
    />
  </>
);

/* eslint-disable sort-keys, flowtype/sort-keys */
type EntityLinkProps = {
  +allowNew?: boolean,
  +content?: ?Expand2ReactOutput,
  +deletedCaption?: string,
  +disableLink?: boolean,
  +entity: CoreEntityT | CollectionT,
  +hover?: string,
  +nameVariation?: boolean,
  +showCaaPresence?: boolean,
  +showDeleted?: boolean,
  +showDisambiguation?: boolean,
  +showEditsPending?: boolean,
  +showEventDate?: boolean,
  +subPath?: string,

  // ...anchorProps
  href?: string,
  title?: string,
  +target?: '_blank',
};
/* eslint-enable sort-keys, flowtype/sort-keys */

const EntityLink = ({
  allowNew = false,
  content,
  deletedCaption,
  disableLink = false,
  entity,
  hover,
  nameVariation,
  showCaaPresence,
  showDeleted = true,
  showDisambiguation,
  showEditsPending = true,
  showEventDate = true,
  subPath,
  ...anchorProps
}: EntityLinkProps):
$ReadOnlyArray<Expand2ReactOutput> | Expand2ReactOutput | null => {
  const hasCustomContent = nonEmpty(content);
  const comment = entity.comment ? ko.unwrap(entity.comment) : '';

  if (showDisambiguation === undefined) {
    showDisambiguation = !hasCustomContent;
  }

  if (entity.entityType === 'artist' && !nonEmpty(hover)) {
    hover = entity.sort_name + (comment ? ' ' + bracketedText(comment) : '');
  }

  if (entity.entityType === 'area') {
    content = content || localizeAreaName(entity);
  } else if (entity.entityType === 'instrument') {
    content = content || localizeInstrumentName(entity);
  }

  content = content || ko.unwrap(entity.name);

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
  if (!subPath && entity.entityType !== 'url') {
    if (nameVariation === undefined && typeof content === 'string') {
      nameVariation = content !== entity.name;
    }

    if (nameVariation) {
      if (hover) {
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
  if (hover) {
    anchorProps.title = hover;
  }
  content = disableLink
    ? (
      <span
        className="deleted"
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

  if (showEditsPending && !subPath && entity.editsPending) {
    content = <span className="mp" key="mp">{content}</span>;
  }

  if (!subPath && entity.entityType === 'area') {
    const isoCodes = entity.iso_3166_1_codes;
    if (isoCodes && isoCodes.length) {
      content = (
        <span className={'flag flag-' + isoCodes[0]} key="flag">
          {content}
        </span>
      );
    }
  }

  if (!subPath && entity.entityType === 'recording' && entity.video) {
    content = (
      <>
        <span className="video" title={l('This recording is a video')} />
        {content}
      </>
    );
  }

  if (showCaaPresence &&
    entity.entityType === 'release' &&
    entity.cover_art_presence === 'present') {
    content = (
      <>
        <a href={'/release/' + entity.gid + '/cover-art'}>
          <span
            className="caa-icon"
            title={l('This release has artwork in the Cover Art Archive')}
          />
        </a>
        {content}
      </>
    );
  }

  if (!subPath && entity.entityType === 'release') {
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
        <>
          <span
            className="low-data-quality"
            title={l(
              `Low quality: The release needs serious fixes, or its existence
               is hard to prove (but it’s not clearly fake)`,
            )}
          />
          {content}
        </>
      );
    }
  }

  if (!showDisambiguation && !infoLink) {
    return content;
  }

  const parts = [content];

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

  if (infoLink) {
    parts.push(
      ' ',
      bracketed(
        <a href={infoLink} key="info">{l('info')}</a>,
        {type: '[]'},
      ),
    );
  }

  return parts;
};

export default EntityLink;
