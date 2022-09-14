/*
 * @flow strict-local
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2019 MetaBrainz Foundation
 *  *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import NotFoundComponent from '../components/NotFound.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

const defaultSearchArgs = {search_url: '/search'};

/* eslint-disable sort-keys */
const notFoundPages = {
  'area': {
    title: N_l('Area Not Found'),
    message: N_l(
      `Sorry, we could not find an area with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'artist': {
    title: N_l('Artist Not Found'),
    message: N_l(
      `Sorry, we could not find an artist with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'artist_credit': {
    title: N_l('Artist Credit Not Found'),
    message: N_l('Sorry, we could not find an artist credit with that ID.'),
    args: {},
    footer: null,
  },
  'cdtoc': {
    title: N_l('CD TOC Not Found'),
    message: N_l('Sorry, we could not find the CD TOC you specified.'),
    args: {},
    footer: null,
  },
  'collection': {
    title: N_l('Collection Not Found'),
    message: N_l(
      'Sorry, we could not find a collection with that MusicBrainz ID.',
    ),
    args: {},
    footer: null,
  },
  'edit': {
    title: N_l('Edit Not Found'),
    message: N_l(
      `Sorry, we could not find an edit with that edit ID.
       You may wish to try and perform an {search_url|edit search} instead.`,
    ),
    args: {search_url: '/search/edits'},
    footer: null,
  },
  'elections': {
    title: N_l('Election Not Found'),
    message: N_l('Sorry, we could not find this election.'),
    args: {},
    footer: <p><a href="/elections">{l('Back to all elections.')}</a></p>,
  },
  'event': {
    title: N_l('Event Not Found'),
    message: N_l(
      `Sorry, we could not find an event with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'genre': {
    title: N_l('Genre Not Found'),
    message: N_l(
      `Sorry, we could not find a genre with that MusicBrainz ID.
       You can see all available genres on our {genre_list|genre list}.`,
    ),
    args: {genre_list: '/genres'},
    footer: null,
  },
  'instrument': {
    title: N_l('Instrument Not Found'),
    message: N_l(
      `Sorry, we could not find an instrument with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'isrc': {
    title: N_l('ISRC Not Currently Used'),
    message: N_l(
      `This ISRC is not associated with any recordings. If you wish to
       associate it with a recording, please
       {search_url|search for the recording} and add it.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'iswc': {
    title: N_l('ISWC Not Currently Used'),
    message: N_l(
      `This ISWC is not associated with any works. If you wish to associate it
       with a work, please {search_url|search for the work} and add it.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'label': {
    title: N_l('Label Not Found'),
    message: N_l(
      `Sorry, we could not find a label with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'otherlookup': {
    title: N_l('Entity Not Found'),
    message: N_l(
      `Sorry, we could not find a MusicBrainz entity with that ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'place': {
    title: N_l('Place Not Found'),
    message: N_l(
      `Sorry, we could not find a place with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'recording': {
    title: N_l('Recording Not Found'),
    message: N_l(
      `Sorry, we could not find a recording with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'relationship/linkattributetype': {
    title: N_l('Relationship Attribute Not Found'),
    message: N_l(
      `Sorry, we could not find a relationship attribute
       with that MusicBrainz ID.`,
    ),
    args: {},
    footer: null,
  },
  'relationship/linktype': {
    title: N_l('Relationship Type Not Found'),
    message: N_l(
      `Sorry, we could not find a relationship type
       with that MusicBrainz ID.`,
    ),
    args: {},
    footer: null,
  },
  'release': {
    title: N_l('Release Not Found'),
    message: N_l(
      `Sorry, we could not find a release with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'release_group': {
    title: N_l('Release Group Not Found'),
    message: N_l(
      `Sorry, we could not find a release group with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'series': {
    title: N_l('Series Not Found'),
    message: N_l(
      `Sorry, we could not find a series with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'track': {
    title: N_l('Track Not Found'),
    message: N_l(
      `Sorry, we could not find neither a recording nor a track with that
       MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'url': {
    title: N_l('URL Not Found'),
    message: N_l('Sorry, we could not find a URL with that MusicBrainz ID.'),
    args: {},
    footer: null,
  },
  'user': {
    title: N_l('Editor Not Found'),
    message: N_l(
      `Sorry, we could not find an editor with that name.
       You may wish to try and {search_url|search for them} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'work': {
    title: N_l('Work Not Found'),
    message: N_l(
      `Sorry, we could not find a work with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
};
/* eslint-enable sort-keys */

type Props = {
  +namespace: string,
};

const NotFound = ({
  namespace,
}: Props): React.Element<typeof NotFoundComponent> => {
  const parameters = notFoundPages[namespace];
  return (
    <NotFoundComponent title={parameters.title()}>
      <p>{expand2react(parameters.message(), parameters.args)}</p>
      {parameters.footer}
    </NotFoundComponent>
  );
};

export default NotFound;
