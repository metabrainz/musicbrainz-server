/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2019 MetaBrainz Foundation
 *  *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import NotFoundComponent from '../components/NotFound.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

const defaultSearchArgs = {search_url: '/search'};

type NotFoundPagesPropsT = {
  +args: {genre_list?: string, search_url?: string},
  +footer: React.Node | null,
  +message: () => string,
  +title: () => string,
};

/* eslint-disable sort-keys */
const notFoundPages: {[namespace: string]: NotFoundPagesPropsT} = {
  'area': {
    title: N_lp('Area not found', 'header'),
    message: N_l(
      `Sorry, we could not find an area with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'artist': {
    title: N_lp('Artist not found', 'header'),
    message: N_l(
      `Sorry, we could not find an artist with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'artist_credit': {
    title: N_lp('Artist credit not found', 'header'),
    message: N_l('Sorry, we could not find an artist credit with that ID.'),
    args: {},
    footer: null,
  },
  'cdtoc': {
    title: N_lp('CD TOC not found', 'header'),
    message: N_l('Sorry, we could not find the CD TOC you specified.'),
    args: {},
    footer: null,
  },
  'collection': {
    title: N_lp('Collection not found', 'header'),
    message: N_l(
      'Sorry, we could not find a collection with that MusicBrainz ID.',
    ),
    args: {},
    footer: null,
  },
  'edit': {
    title: N_lp('Edit not found', 'header'),
    message: N_l(
      `Sorry, we could not find an edit with that edit ID.
       You may wish to try and perform an {search_url|edit search} instead.`,
    ),
    args: {search_url: '/search/edits'},
    footer: null,
  },
  'elections': {
    title: N_lp('Election not found', 'header'),
    message: N_l('Sorry, we could not find this election.'),
    args: {},
    footer: <p><a href="/elections">{l('Back to all elections.')}</a></p>,
  },
  'event': {
    title: N_lp('Event not found', 'header'),
    message: N_l(
      `Sorry, we could not find an event with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'genre': {
    title: N_lp('Genre not found', 'header'),
    message: N_l(
      `Sorry, we could not find a genre with that MusicBrainz ID.
       You can see all available genres on our {genre_list|genre list}.`,
    ),
    args: {genre_list: '/genres'},
    footer: null,
  },
  'instrument': {
    title: N_lp('Instrument not found', 'header'),
    message: N_l(
      `Sorry, we could not find an instrument with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'isrc': {
    title: N_lp('ISRC not currently used', 'header'),
    message: N_l(
      `This ISRC is not associated with any recordings. If you wish to
       associate it with a recording, please
       {search_url|search for the recording} and add it.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'iswc': {
    title: N_lp('ISWC not currently used', 'header'),
    message: N_l(
      `This ISWC is not associated with any works. If you wish to associate it
       with a work, please {search_url|search for the work} and add it.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'label': {
    title: N_lp('Label not found', 'header'),
    message: N_l(
      `Sorry, we could not find a label with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'otherlookup': {
    title: N_lp('Entity not found', 'header'),
    message: N_l(
      `Sorry, we could not find a MusicBrainz entity with that ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'place': {
    title: N_lp('Place not found', 'header'),
    message: N_l(
      `Sorry, we could not find a place with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'recording': {
    title: N_lp('Recording not found', 'header'),
    message: N_l(
      `Sorry, we could not find a recording with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'relationship/linkattributetype': {
    title: N_lp('Relationship attribute not found', 'header'),
    message: N_l(
      `Sorry, we could not find a relationship attribute
       with that MusicBrainz ID.`,
    ),
    args: {},
    footer: null,
  },
  'relationship/linktype': {
    title: N_lp('Relationship type not found', 'header'),
    message: N_l(
      `Sorry, we could not find a relationship type
       with that MusicBrainz ID.`,
    ),
    args: {},
    footer: null,
  },
  'release': {
    title: N_lp('Release not found', 'header'),
    message: N_l(
      `Sorry, we could not find a release with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'release_group': {
    title: N_lp('Release group not found', 'header'),
    message: N_l(
      `Sorry, we could not find a release group with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'series': {
    title: N_lp('Series not found', 'singular, header'),
    message: N_l(
      `Sorry, we could not find a series with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'track': {
    title: N_lp('Track not found', 'header'),
    message: N_l(
      `Sorry, we could not find neither a recording nor a track with that
       MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'url': {
    title: N_lp('URL not found', 'header'),
    message: N_l('Sorry, we could not find a URL with that MusicBrainz ID.'),
    args: {},
    footer: null,
  },
  'user': {
    title: N_lp('Editor not found', 'header'),
    message: N_l(
      `Sorry, we could not find an editor with that name.
       You may wish to try and {search_url|search for them} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
  'work': {
    title: N_lp('Work not found', 'header'),
    message: N_l(
      `Sorry, we could not find a work with that MusicBrainz ID.
       You may wish to try and {search_url|search for it} instead.`,
    ),
    args: defaultSearchArgs,
    footer: null,
  },
};
/* eslint-enable sort-keys */

component NotFound(namespace: $Keys<typeof notFoundPages>) {
  const parameters = notFoundPages[namespace];
  return (
    <NotFoundComponent title={parameters.title()}>
      <p>{expand2react(parameters.message(), parameters.args)}</p>
      {parameters.footer}
    </NotFoundComponent>
  );
}

export default NotFound;
