/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import {FAVICON_CLASSES} from '../../static/scripts/common/constants.js';
import {compare, l} from '../../static/scripts/common/i18n.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';
import {uniqBy} from '../../static/scripts/common/utility/arrays.js';
import isDisabledLink
  from '../../static/scripts/common/utility/isDisabledLink.js';

function faviconClass(urlEntity: UrlT) {
  let matchingClass;
  const urlObject = new URL(urlEntity.name);

  for (const key in FAVICON_CLASSES) {
    if ((key.indexOf('/') >= 0 && urlEntity.name.indexOf(key) >= 0) ||
        (urlObject.host?.indexOf(key) ?? -1) >= 0) {
      matchingClass = FAVICON_CLASSES[key];
      break;
    }
  }

  return (matchingClass || 'no') + '-favicon';
}

type ExternalLinkProps = {
  +className?: string,
  +editsPending: boolean,
  +entityCredit: string,
  +text?: string,
  +url: UrlT,
};

const ExternalLink = ({
  className,
  editsPending,
  entityCredit,
  text,
  url,
}: ExternalLinkProps) => {
  let element: Expand2ReactOutput = (
    <a href={url.href_url}>
      {nonEmpty(text) ? text : url.sidebar_name}
    </a>
  );

  if (nonEmpty(entityCredit)) {
    element = exp.l(
      '{url} (as {credited_name})',
      {credited_name: entityCredit, url: element},
    );
  }

  if (editsPending) {
    element = <span className="mp mp-rel">{element}</span>;
  }

  if (url.editsPending) {
    element = <span className="mp">{element}</span>;
  }

  return (
    <li className={nonEmpty(className) ? className : faviconClass(url)}>
      {element}
    </li>
  );
};

type Props = {
  empty: boolean,
  entity: CentralEntityT,
  heading?: string,
};

const ExternalLinks = ({
  entity,
  empty,
  heading,
}: Props): React.MixedElement | null => {
  const relationships = entity.relationships;
  if (!relationships) {
    return null;
  }

  const links = [];
  const blogLinks = [];
  const otherLinks: Array<{
    +editsPending: boolean,
    +entityCredit: string,
    +id: number,
    +url: UrlT,
  }> = [];

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const target = relationship.target;
    const entityCredit = entity.id === relationship.entity0_id
      ? relationship.entity0_credit
      : relationship.entity1_credit;

    if (target.entityType !== 'url' || isDisabledLink(relationship, target)) {
      continue;
    }

    const linkType =
      linkedEntities.link_type[relationship.linkTypeID];
    if (/^official (?:homepage|site)$/.test(linkType.name)) {
      links.push(
        <ExternalLink
          className="home-favicon"
          editsPending={relationship.editsPending}
          entityCredit={entityCredit}
          key={relationship.id}
          text={l('Official homepage')}
          url={target}
        />,
      );
    } else if (/^blog$/.test(linkType.name)) {
      blogLinks.push(
        <ExternalLink
          className="blog-favicon"
          editsPending={relationship.editsPending}
          entityCredit={entityCredit}
          key={relationship.id}
          text={l('Blog')}
          url={target}
        />,
      );
    } else if (target.show_in_external_links /*:: === true */) {
      otherLinks.push({
        editsPending: relationship.editsPending,
        entityCredit: entityCredit,
        id: relationship.id,
        url: target,
      });
    }
  }

  if (!(links.length || blogLinks.length || otherLinks.length)) {
    return null;
  }

  const uniqueOtherLinks =
    uniqBy(otherLinks, x => x.url.href_url).sort((a, b) => (
      compare(
        a.url.sidebar_name ?? '',
        b.url.sidebar_name ?? '',
      ) ||
      compare(a.url.href_url, b.url.href_url)
    ));

  // We ensure official sites are listed above blogs, and blogs above others
  links.push(...blogLinks);
  links.push(...uniqueOtherLinks.map(({id, ...props}) => (
    <ExternalLink key={id} {...props} />
  )));

  const entityType = entity.entityType;

  return (
    <>
      <h2 className="external-links">
        {nonEmpty(heading) ? heading : l('External links')}
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
