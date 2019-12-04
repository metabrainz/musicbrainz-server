/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import URL from 'url';

import React from 'react';
import _ from 'lodash';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import {FAVICON_CLASSES} from '../../static/scripts/common/constants';
import {compare, l} from '../../static/scripts/common/i18n';
import linkedEntities from '../../static/scripts/common/linkedEntities';

function faviconClass(urlEntity) {
  let matchingClass;
  const urlObject = URL.parse(urlEntity.name, false, true);

  for (const key in FAVICON_CLASSES) {
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
  const relationships = entity.relationships;
  const links = [];
  const blogLinks = [];
  const otherLinks = [];

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const target = relationship.target;

    if (relationship.ended || target.entityType !== 'url') {
      continue;
    }

    const linkType =
      linkedEntities.link_type[relationship.linkTypeID];
    if (/^official (?:homepage|site)$/.test(linkType.name)) {
      links.push(
        <ExternalLink
          className="home-favicon"
          key={relationship.id}
          relationship={relationship}
          text={l('Official homepage')}
        />,
      );
    } else if (/^blog$/.test(linkType.name)) {
      blogLinks.push(
        <ExternalLink
          className="blog-favicon"
          key={relationship.id}
          relationship={relationship}
          text={l('Blog')}
        />,
      );
    } else if (target.show_in_external_links) {
      otherLinks.push(relationship);
    }
  }

  if (!(links.length || blogLinks.length || otherLinks.length)) {
    return null;
  }

  otherLinks.sort(function (a, b) {
    return compare(a.target.sidebar_name, b.target.sidebar_name) ||
      compare(a.target.href_url, b.target.href_url);
  });

  const uniqueOtherLinks = _.sortedUniqBy(otherLinks, x => x.target.href_url);

  // We ensure official sites are listed above blogs, and blogs above others
  links.push.apply(links, blogLinks);
  links.push.apply(links, uniqueOtherLinks.map(function (relationship) {
    return <ExternalLink key={relationship.id} relationship={relationship} />;
  }));

  const entityType = entity.entityType;

  return (
    <>
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
    </>
  );
};

export default ExternalLinks;
