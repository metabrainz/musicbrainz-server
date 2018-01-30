// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');
const URL = require('url');

const Frag = require('../../components/Frag');
const EntityLink =
  require('../../static/scripts/common/components/EntityLink');
const {FAVICON_CLASSES} = require('../../static/scripts/common/constants');
const {compare, l} = require('../../static/scripts/common/i18n');

function faviconClass(urlEntity) {
  let matchingClass;
  let urlObject = URL.parse(urlEntity.name, false, true);

  for (let key in FAVICON_CLASSES) {
    if ((key.indexOf('/') >= 0 && urlEntity.name.indexOf(key) >= 0) ||
        urlObject.host.indexOf(key) >= 0) {
      matchingClass = FAVICON_CLASSES[key];
      break;
    }
  }

  return (matchingClass || 'no') + '-favicon';
}

const ExternalLink = ({className, relationship, text}) => {
  const url = relationship.target;
  let element = <a href={url.href_url}>{text || url.sidebar_name}</a>;

  if (relationship.editsPending) {
    element = <span className="mp mp-rel">{element}</span>;
  }

  if (url.editsPending) {
    element = <span className="mp">{element}</span>;
  }

  return (
    <li className={className || faviconClass(url)}>
      {element}
    </li>
  );
};

const ExternalLinks = ({entity, empty, heading}) => {
  if (!entity) {
    entity = $c.stash.entity;
  }

  const relationships = entity.relationships;
  const links = [];
  const otherLinks = [];

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const target = relationship.target;

    if (relationship.ended || target.entityType !== 'url') {
      continue;
    }

    const linkType =
      $c.stash.linked_entities.link_type[relationship.linkTypeID];
    if (/^official (?:homepage|site)$/.test(linkType.name)) {
      links.push(
        <ExternalLink
          className="home-favicon"
          key={relationship.id}
          relationship={relationship}
          text={l('Official homepage')}
        />
      );
    } else if (target.show_in_external_links) {
      otherLinks.push(relationship);
    }
  }

  if (!(links.length || otherLinks.length)) {
    return null;
  }

  otherLinks.sort(function (a, b) {
    return compare(a.target.sidebar_name, b.target.sidebar_name);
  });

  links.push.apply(links, otherLinks.map(function (relationship) {
    return <ExternalLink key={relationship.id} relationship={relationship} />;
  }));

  const entityType = entity.entityType;

  return (
    <Frag>
      <h2 className="external-links">
        {heading || l('External links')}
      </h2>
      <ul className="external_links">
        {links}
        {(empty && (entityType === 'artist' || entityType === 'label')) ? (
          <li className="all-relationships">
            <EntityLink
              content={l('View all relationships')}
              entity={entity}
              subPath="relationships"
            />
          </li>
        ) : null}
      </ul>
    </Frag>
  );
};

module.exports = ExternalLinks;
