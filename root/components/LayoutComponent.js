/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaLayout from '../area/AreaLayout.js';
import ArtistLayout from '../artist/ArtistLayout.js';
import CollectionLayout from '../collection/CollectionLayout.js';
import EventLayout from '../event/EventLayout.js';
import GenreLayout from '../genre/GenreLayout.js';
import InstrumentLayout from '../instrument/InstrumentLayout.js';
import LabelLayout from '../label/LabelLayout.js';
import PlaceLayout from '../place/PlaceLayout.js';
import RecordingLayout from '../recording/RecordingLayout.js';
import ReleaseLayout from '../release/ReleaseLayout.js';
import ReleaseGroupLayout from '../release_group/ReleaseGroupLayout.js';
import SeriesLayout from '../series/SeriesLayout.js';
import WorkLayout from '../work/WorkLayout.js';

import UserAccountLayout, {type AccountLayoutUserT}
  from './UserAccountLayout.js';

type LayoutEntityT =
  | NonUrlRelatableEntityT
  | AccountLayoutUserT
  | CollectionT;

export default component LayoutComponent(
  children: React.Node,
  entity: LayoutEntityT,
  // Fixme: actually pass hasReleases
  hasReleases: boolean = false,
  fullWidth: boolean = false,
  page: string = '',
  title: string,
) {
  const sharedProps = {
    fullWidth,
    page,
    title,
  };

  return match (entity) {
    {entityType: 'area', ...} as area => (
      <AreaLayout entity={area} {...sharedProps}>{children}</AreaLayout>
    ),
    {entityType: 'artist', ...} as artist => (
      <ArtistLayout entity={artist} {...sharedProps}>{children}</ArtistLayout>
    ),
    {entityType: 'collection', ...} as collection => (
      <CollectionLayout entity={collection} {...sharedProps}>
        {children}
      </CollectionLayout>
    ),
    {entityType: 'editor', ...} as editor => (
      <UserAccountLayout entity={editor} page={page} title={title}>
        {children}
      </UserAccountLayout>
    ),
    {entityType: 'event', ...} as event => (
      <EventLayout entity={event} {...sharedProps}>{children}</EventLayout>
    ),
    {entityType: 'genre', ...} as genre => (
      <GenreLayout entity={genre} {...sharedProps}>{children}</GenreLayout>
    ),
    {entityType: 'instrument', ...} as instrument => (
      <InstrumentLayout entity={instrument} {...sharedProps}>
        {children}
      </InstrumentLayout>
    ),
    {entityType: 'label', ...} as label => (
      <LabelLayout entity={label} {...sharedProps}>{children}</LabelLayout>
    ),
    {entityType: 'place', ...} as place => (
      <PlaceLayout entity={place} {...sharedProps}>{children}</PlaceLayout>
    ),
    {entityType: 'recording', ...} as recording => (
      <RecordingLayout entity={recording} {...sharedProps}>
        {children}
      </RecordingLayout>
    ),
    {entityType: 'release', ...} as release => (
      <ReleaseLayout entity={release} {...sharedProps}>
        {children}
      </ReleaseLayout>
    ),
    {entityType: 'release_group', ...} as releaseGroup => (
      <ReleaseGroupLayout
        entity={releaseGroup}
        hasReleases={hasReleases}
        {...sharedProps}
      >
        {children}
      </ReleaseGroupLayout>
    ),
    {entityType: 'series', ...} as series => (
      <SeriesLayout entity={series} {...sharedProps}>{children}</SeriesLayout>
    ),
    {entityType: 'work', ...} as work => (
      <WorkLayout entity={work} {...sharedProps}>{children}</WorkLayout>
    ),
  };
// eslint-disable-next-line @stylistic/semi -- bug, wants unneeded semi
}
