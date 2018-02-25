// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const ko = require('knockout');
const _ = require('lodash');
const React = require('react');

const Frag = require('../../../../components/Frag');
const {ENTITIES, AREA_TYPE_COUNTRY} = require('../constants');
const {l} = require('../i18n');
const bracketed = require('../utility/bracketed');
const entityHref = require('../utility/entityHref');
const formatDatePeriod = require('../utility/formatDatePeriod');
const isolateText = require('../utility/isolateText');
const nonEmpty = require('../utility/nonEmpty');
const reactTextContent = require('../utility/reactTextContent');

const DeletedLink = ({name, allowNew}) => {
  let caption = allowNew
    ? l('This entity will be created when edits are entered.')
    : l('This entity has been removed, and cannot be displayed correctly.');

  return (
    <span className={(allowNew ? '' : 'deleted ') + 'tooltip'} title={caption}>
      {isolateText(name || l('[removed]'))}
    </span>
  );
};

const Comment = ({className, comment}) => (
  <Frag>
    {' '}
    <span className={className}>({isolateText(comment)})</span>
  </Frag>
);

class EventDisambiguation extends React.Component {
  render() {
    let event = this.props.event;
    let dates = formatDatePeriod(event);
    if (!dates && !event.cancelled) {
      return null;
    }
    return (
      <Frag>
        {dates ? bracketed(dates) : null}
        {event.cancelled
          ? <Comment className="cancelled" comment={l('cancelled')} />
          : null}
      </Frag>
    );
  }
}

class AreaDisambiguation extends React.Component {
  render() {
    let area = this.props.area;

    if (!area.ended) {
      return null;
    }

    let comment;
    let beginYear = area.begin_date ? area.begin_date.year : null;
    let endYear = area.end_date ? area.end_date.year : null;

    if (beginYear && endYear) {
      comment = l('historical, {begin}-{end}', {begin: beginYear, end: endYear});
    } else if (endYear) {
      comment = l('historical, until {end}', {end: endYear});
    } else {
      comment = l('historical');
    }

    return <Comment className="historical" comment={comment} />;
  }
}

const NoInfoURL = ({url, allowNew}) => (
  <Frag>
    <a href={url}>{url}</a>
    {' '}
    <DeletedLink name={'[' + l('info') + ']'} allowNew={allowNew} />
  </Frag>
);

const EntityLink = (props = {}) => {
  let {
    allowNew,
    content,
    entity,
    hover,
    showDeleted = true,
    showDisambiguation,
    subPath,
    ...anchorProps
  } = props;

  const hasCustomContent = nonEmpty(content);
  const entityType = entity.entityType;
  const comment = ko.unwrap(entity.comment);

  if (showDisambiguation === undefined) {
    showDisambiguation = !hasCustomContent;
  }

  if (entityType === 'artist' && !nonEmpty(hover)) {
    hover = entity.sort_name + bracketed(comment);
  }

  if (entityType === 'artist' || entityType === 'instrument') {
    content = content || entity.l_name;
  }

  content = content || ko.unwrap(entity.name);

  if (!ko.unwrap(entity.gid)) {
    if (entityType === 'url') {
      return <NoInfoURL url={entity.url} allowNew={allowNew} />;
    }
    if (showDeleted) {
      return <DeletedLink name={content} allowNew={allowNew} />;
    }
    return null;
  }

  let href = entityHref(entity, subPath);
  let nameVariation;
  let infoLink;

  if (entityType === 'url' && !hasCustomContent) {
    content = entity.pretty_name;
    infoLink = href;
    href = entity.href_url;
  }

  // TODO: support name variations for all entity types?
  if (!subPath && (entityType === 'artist' || entityType === 'recording')) {
    nameVariation = (_.isObject(content) ? reactTextContent(content) : content) !== entity.name;

    if (nameVariation) {
      if (hover) {
        hover = l('{name} – {additional_info}', {name: entity.name, additional_info: hover});
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

  if (!subPath && entity.editsPending) {
    content = <span className="mp" key="mp">{content}</span>;
  }

  if (!subPath && entityType === 'area') {
    let isoCodes = entity.iso_3166_1_codes;
    if (isoCodes && isoCodes.length) {
      content = (
        <span className={'flag flag-' + isoCodes[0]} key="flag">
          {content}
        </span>
      );
    }
  }

  if (!showDisambiguation && !infoLink) {
    return content;
  }

  const parts = [content];

  if (showDisambiguation) {
    if (entityType === 'event') {
      parts.push(<EventDisambiguation event={entity} key="eventdisambig" />);
    }
    if (comment) {
      parts.push(
        <Comment className="comment" comment={comment} key="comment" />
      );
    }
    if (entityType === 'area') {
      parts.push(<AreaDisambiguation area={entity} key="areadisambig" />);
    }
  }

  if (infoLink) {
    parts.push(' [', <a href={infoLink} key="info">{l('info')}</a>, ']')
  }

  return parts;
};

module.exports = EntityLink;
