/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';

import localizeAreaName from '../i18n/localizeAreaName';
import localizeInstrumentName from '../i18n/localizeInstrumentName';
import bracketed, {bracketedText} from '../utility/bracketed';
import entityHref from '../utility/entityHref';
import formatDatePeriod from '../utility/formatDatePeriod';
import isolateText from '../utility/isolateText';
import nonEmpty from '../utility/nonEmpty';
import reactTextContent from '../utility/reactTextContent';

export const DeletedLink = ({
  allowNew,
  name,
}: {|+allowNew: boolean, +name: React.Node|}) => {
  const caption = allowNew
    ? l('This entity will be created when edits are entered.')
    : l('This entity has been removed, and cannot be displayed correctly.');

  return (
    <span className={(allowNew ? '' : 'deleted ') + 'tooltip'} title={caption}>
      {isolateText(name || l('[removed]'))}
    </span>
  );
};

const Comment = ({
  className,
  comment,
}: {|+className: string, +comment: string|}) => (
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
}: {|+event: EventT, +showDate: boolean|}) => {
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

const AreaDisambiguation = ({area}: {|+area: AreaT|}) => {
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

const NoInfoURL = ({allowNew, url}: {|+allowNew: boolean, +url: string|}) => (
  <>
    <a href={url}>{url}</a>
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
  +content?: React.Node,
  +entity: CoreEntityT | CollectionT,
  +hover?: string,
  +nameVariation?: boolean,
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
  entity,
  hover,
  nameVariation,
  showDeleted = true,
  showDisambiguation,
  showEditsPending = true,
  showEventDate = true,
  subPath,
  ...anchorProps
}: EntityLinkProps) => {
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
      return <DeletedLink allowNew={allowNew} name={content} />;
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

  // TODO: support name variations for all entity types?
  if (!subPath &&
      (entity.entityType === 'artist' || entity.entityType === 'recording')) {
    if (nameVariation === undefined) {
      nameVariation = (
        React.isValidElement(content)
          ? reactTextContent(content)
          : content
      ) !== entity.name;
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
  content = <a key="link" {...anchorProps}>{isolateText(content)}</a>;

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
