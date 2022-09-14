/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {ENTITIES} from '../static/scripts/common/constants.js';
import isSpecialPurpose
  from '../static/scripts/common/utility/isSpecialPurpose.js';
import {
  isLocationEditor,
  isRelationshipEditor,
} from '../static/scripts/common/utility/privileges.js';

import EntityTabLink from './EntityTabLink.js';
import Tabs from './Tabs.js';

const tabLinkNames = {
  artists: N_l('Artists'),
  events: N_l('Events'),
  fingerprints: N_l('Fingerprints'),
  labels: N_l('Labels'),
  map: N_l('Map'),
  performances: N_l('Performances'),
  places: N_l('Places'),
  recordings: N_l('Recordings'),
  releases: N_l('Releases'),
  users: N_l('Users'),
  works: N_l('Works'),
};

const buildLink = (
  content: string,
  entity: CoreEntityT,
  subPath: string,
  page: ?string,
  disabled?: boolean = false,
  pageName?: string = subPath,
) => (
  <EntityTabLink
    content={content}
    disabled={disabled}
    entity={entity}
    key={subPath}
    selected={pageName === page}
    subPath={subPath}
  />
);

function showEditTab(
  user: ?UnsanitizedEditorT,
  entity: CoreEntityT,
): boolean {
  switch (entity.entityType) {
    case 'area':
      return isLocationEditor(user);
    case 'artist':
      return !isSpecialPurpose(entity);
    case 'genre':
    case 'instrument':
      return isRelationshipEditor(user);
    case 'label':
      return !isSpecialPurpose(entity);
    default:
      return true;
  }
}

function buildLinks(
  $c: CatalystContextT,
  entity: CoreEntityT,
  page?: string,
  editTab: ?React.Element<typeof EntityTabLink>,
): $ReadOnlyArray<React.Element<typeof EntityTabLink>> {
  const links = [buildLink(l('Overview'), entity, '', page, false, 'index')];
  const user = $c.user;

  const entityProperties = ENTITIES[entity.entityType];

  if (entityProperties.custom_tabs) {
    entityProperties.custom_tabs.forEach((tab) => {
      links.push(buildLink(tabLinkNames[tab](), entity, tab, page));
    });
  }

  if (entityProperties.mbid.relatable === 'dedicated') {
    links.push(buildLink(l('Relationships'), entity, 'relationships', page));
  }

  if (entity.entityType === 'release') {
    // Drop # + grey out if can't have discIDs unless it has them due to bug
    const enabledDiscIdTab = entity.may_have_discids /*:: === true */ ||
      ($c.stash.release_cdtoc_count || 0) > 0;
    links.push(buildLink(
      enabledDiscIdTab
        ? texp.l(
          'Disc IDs ({num})',
          {num: $c.stash.release_cdtoc_count || 0},
        )
        : l('Disc IDs'),
      entity,
      'discids',
      page,
      !enabledDiscIdTab, /* disable tab if irrelevant */
    ));
  }

  if (entityProperties.cover_art) {
    links.push(buildLink(
      entity.cover_art_presence === 'darkened' ? l('Cover Art') : (
        texp.l(
          'Cover Art ({num})',
          {num: $c.stash.release_artwork_count || 0},
        )
      ),
      entity,
      'cover-art',
      page,
    ));
  }

  if (entityProperties.aliases) {
    links.push(buildLink(l('Aliases'), entity, 'aliases', page));
  }

  if (entityProperties.tags) {
    links.push(buildLink(l('Tags'), entity, 'tags', page));
  }

  if (
    entityProperties.ratings ||
    // $FlowIssue[prop-missing]
    entityProperties.reviews
  ) {
    const ratingsTabTitle = entityProperties.reviews
      ? l('Reviews')
      : l('Ratings');
    links.push(buildLink(ratingsTabTitle, entity, 'ratings', page));
  }

  if (!entityProperties.mbid.no_details) {
    links.push(buildLink(l('Details'), entity, 'details', page));
  }

  if (showEditTab(user, entity)) {
    if (editTab) {
      links.push(editTab);
    } else {
      links.push(buildLink(l('Edit'), entity, 'edit', page));
    }
  }

  if (entity.entityType === 'release') {
    links.push(buildLink(
      l('Edit Relationships'),
      entity,
      'edit-relationships',
      page,
    ));
  }

  return links;
}

type Props = {
  +editTab: ?React.Element<typeof EntityTabLink>,
  +entity: CoreEntityT,
  +page?: string,
};

const EntityTabs = ({
  editTab,
  entity,
  page,
}: Props): React.Element<typeof Tabs> => (
  <Tabs>
    <CatalystContext.Consumer>
      {($c: CatalystContextT) => buildLinks($c, entity, page, editTab)}
    </CatalystContext.Consumer>
  </Tabs>
);

export default EntityTabs;
