/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {CatalystContext} = require('../context');
const {l, N_l} = require('../static/scripts/common/i18n');
const Tabs = require('./Tabs');
const EntityTabLink = require('./EntityTabLink');
const EntityLink = require('../static/scripts/common/components/EntityLink');
const {ENTITIES} = require('../static/scripts/common/constants');
const isSpecialPurposeArtist = require('../static/scripts/common/utility/isSpecialPurposeArtist');

const tabLinkNames = {
  artists: N_l('Artists'),
  cover_art: N_l('Cover Art'),
  discids: N_l('Disc IDs'),
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
  content,
  entity,
  subPath,
  page,
  pageName = subPath,
) => (
  <EntityTabLink
    content={content}
    entity={entity}
    key={subPath}
    selected={pageName === page}
    subPath={subPath}
  />
);

function showEditTab(
  user: ?EditorT,
  entity: CoreEntityT,
): boolean {
  switch (entity.entityType) {
    case 'area':
      return user ? user.is_location_editor : false;
    case 'artist':
      return !isSpecialPurposeArtist(entity);
    case 'instrument':
      return user ? user.is_relationship_editor : false;
    default:
      return true;
  }
}

function buildLinks(
  user: ?EditorT,
  entity: CoreEntityT,
  page: string,
  editTab: React.Node,
): React.Node {
  const links = [buildLink(l('Overview'), entity, 'show', page, 'index')];

  const entityProperties = ENTITIES[entity.entityType];

  if (entityProperties.custom_tabs) {
    entityProperties.custom_tabs.forEach((tab) => {
      links.push(buildLink(l(tabLinkNames[tab]), entity, tab, page));
    });
  }

  if (entityProperties.mbid.relatable === 'dedicated') {
    links.push(buildLink(l('Relationships'), entity, 'relationships', page));
  }

  if (entityProperties.aliases) {
    links.push(buildLink(l('Aliases'), entity, 'aliases', page));
  }

  if (entityProperties.tags) {
    links.push(buildLink(l('Tags'), entity, 'tags', page));
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

  return links;
}

type Props = {|
  +editTab: React.Node,
  +entity: CoreEntityT,
  +page: string,
|};

const EntityTabs = ({
  editTab,
  entity,
  page,
}: Props) => (
  <Tabs>
    <CatalystContext.Consumer>
      {($c: CatalystContextT) => buildLinks($c.user, entity, page, editTab)}
    </CatalystContext.Consumer>
  </Tabs>
);

module.exports = EntityTabs;
