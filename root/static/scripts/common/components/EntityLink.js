// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const {ENTITIES, AREA_TYPE_COUNTRY} = require('../constants');
const {l} = require('../i18n');
const bracketed = require('../utility/bracketed');
const entityHREF = require('../utility/entityHREF');
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
  <frag>
    {' '}
    <span className={className}>({isolateText(comment)})</span>
  </frag>
);

class EventDisambiguation extends React.Component {
  render() {
    let event = this.props.event;
    let dates = formatDatePeriod(event);
    if (!dates && !event.cancelled) {
      return null;
    }
    return (
      <frag>
        <If condition={dates}>
          {bracketed(dates)}
        </If>
        <If condition={event.cancelled}>
          <Comment className="cancelled" comment={l('cancelled')} />
        </If>
      </frag>
    );
  }
}

const leadingInt = /^([0-9]+)/;

class AreaDisambiguation extends React.Component {
  render() {
    let area = this.props.area;

    if (!area.ended) {
      return null;
    }

    let comment;
    let beginYear = area.begin_date.replace(leadingInt, '$1');
    let endYear = area.end_date.replace(leadingInt, '$1');

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
  <frag>
    <a href={url}>{url}</a>
    {' '}
    <DeletedLink name={'[' + l('info') + ']'} allowNew={allowNew} />
  </frag>
);

const EntityLink = (props = {}) => {
  let {
    allowNew,
    content,
    entity,
    hover,
    showDisambiguation,
    subPath,
    ...anchorProps
  } = props;

  let hasCustomContent = nonEmpty(content);
  let entityType = entity.entityType;

  if (showDisambiguation === undefined) {
    showDisambiguation = !hasCustomContent;
  }

  if (entityType === 'artist' && !nonEmpty(hover)) {
    hover = entity.sortName + bracketed(entity.comment);
  }

  if (entityType === 'artist' || entityType === 'instrument') {
    content = content || entity.l_name;
  }

  content = content || entity.name;

  if (!entity.gid) {
    if (entityType === 'url') {
      return <NoInfoURL url={entity.url} allowNew={allowNew} />;
    }
    return <DeletedLink name={content} allowNew={allowNew} />;
  }

  let href = entityHREF(entityType, entity.gid, subPath);
  let nameVariation;
  let infoLink;

  if (entityType === 'url' && !hasCustomContent) {
    content = entity.pretty_name;
    infoLink = href;
    href = entity.href;
  }

  // TODO: support name variations for all entity types?
  if (!subPath && (entityType === 'artist' || entityType === 'recording')) {
    nameVariation = (_.isObject(content) ? reactTextContent(content) : content) !== entity.name;

    if (nameVariation) {
      if (hover) {
        hover = l('{name} – {additional_info}', {name: entity.name, additional_info: hover});
      } else {
        hover = entity.name;
      }
    }
  }

  anchorProps.href = href;
  if (hover) {
    anchorProps.title = hover;
  }
  content = <a {...anchorProps}>{isolateText(content)}</a>;

  if (nameVariation) {
    content = <span className="name-variation">{content}</span>;
  }

  if (!subPath && entity.editsPending) {
    content = <span className="mp">{content}</span>;
  }

  if (!subPath && entityType === 'area') {
    let isoCodes = entity.iso_3166_1_codes;
    if (isoCodes && isoCodes.length) {
      content = <span className={'flag flag-' + isoCodes[0]}>{content}</span>;
    }
  }

  if (!showDisambiguation && !infoLink) {
    return content;
  }

  return (
    <frag>
      {content}
      <If condition={showDisambiguation}>
        <If condition={entityType === 'event'}>
          <EventDisambiguation event={entity} />
        </If>
        <If condition={entity.comment}>
          <Comment className="comment" comment={entity.comment} />
        </If>
        <If condition={entityType === 'area'}>
          <AreaDisambiguation area={entity} />
        </If>
      </If>
      <If condition={infoLink}>
        {' '}
        [<a href={infoLink}>{l('info')}</a>]
      </If>
    </frag>
  );
};

module.exports = EntityLink;
