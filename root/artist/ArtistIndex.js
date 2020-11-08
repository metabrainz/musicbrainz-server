/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import Filter from '../static/scripts/common/components/Filter';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import {addColonText} from '../static/scripts/common/i18n/addColon';
import commaOnlyList, {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList';
import {bracketedText} from '../static/scripts/common/utility/bracketed';
import FormSubmit from '../components/FormSubmit';
import RecordingList from '../components/list/RecordingList';
import ReleaseGroupList from '../components/list/ReleaseGroupList';
import PaginatedResults from '../components/PaginatedResults';
import * as manifest from '../static/manifest';
import entityHref from '../static/scripts/common/utility/entityHref';
import {returnToCurrentPage} from '../utility/returnUri';

import ArtistLayout from './ArtistLayout';

type RelatedArtistsProps = {
  +children: React$Node,
  +title: string,
};

const RelatedArtists = ({children, title}: RelatedArtistsProps) => (
  <p>
    <strong>{addColonText(title)}</strong>
    {' '}
    {children}
  </p>
);

type Props = {
  +$c: CatalystContextT,
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +eligibleForCleanup: boolean,
  +filterForm: ?FilterFormT,
  +hasFilter: boolean,
  +includingAllStatuses: boolean,
  +legalName: ?ArtistT,
  +legalNameAliases: ?$ReadOnlyArray<string>,
  +legalNameArtistAliases: ?$ReadOnlyArray<string>,
  +numberOfRevisions: number,
  +otherIdentities: $ReadOnlyArray<ArtistT>,
  +pager: PagerT,
  +recordings: ?$ReadOnlyArray<RecordingT>,
  +releaseGroups: ?$ReadOnlyArray<ReleaseGroupT>,
  +showingVariousArtistsOnly: boolean,
  +wantAllStatuses: boolean,
  +wantVariousArtistsOnly: boolean,
  +wikipediaExtract: WikipediaExtractT,
};

const ArtistIndex = ({
  $c,
  ajaxFilterFormUrl,
  artist,
  eligibleForCleanup,
  filterForm,
  hasFilter,
  includingAllStatuses,
  legalName,
  legalNameAliases,
  legalNameArtistAliases,
  numberOfRevisions,
  otherIdentities,
  pager,
  recordings,
  releaseGroups,
  showingVariousArtistsOnly,
  wantAllStatuses,
  wantVariousArtistsOnly,
  wikipediaExtract,
}: Props): React.Element<typeof ArtistLayout> => {
  const existingRecordings = recordings?.length ? recordings : null;
  const existingReleaseGroups = releaseGroups?.length ? releaseGroups : null;
  const artistLink = entityHref(artist);
  let message = '';

  if (existingRecordings) {
    message = l(
      'This artist has no release groups, only standalone recordings.',
    );
  } else if (!existingReleaseGroups && hasFilter) {
    message = l('No release groups found that match this search.');
  } else if (!wantAllStatuses && !wantVariousArtistsOnly) {
    if (!includingAllStatuses && !showingVariousArtistsOnly) {
      if (existingReleaseGroups) {
        message = exp.l(
          `Showing official release groups by this artist.
           {show_all|Show all release groups instead}, or
           {show_va|show various artists release groups}.`,
          {
            show_all: `${artistLink}?all=1`,
            show_va: `${artistLink}?va=1`,
          },
        );
      } else {
        message = l(`This artist does not have any release groups or
                     standalone recordings.`);
      }
    } else if (includingAllStatuses && !showingVariousArtistsOnly) {
      message = (
        <>
          {l('This artist only has unofficial release groups.')}
          {' '}
          {exp.l(
            `Showing all release groups by this artist.
             {show_va|Show various artists release groups instead}.`,
            {show_va: `${artistLink}?va=1`},
          )}
        </>
      );
    } else if (!includingAllStatuses && showingVariousArtistsOnly) {
      message = (
        <>
          {l('This artist only has release groups by various artists.')}
          {' '}
          {exp.l(
            `Showing official release groups for various artists.
             {show_all|Show all various artists release groups instead}.`,
            {show_all: `${artistLink}?all=1&va=1`},
          )}
        </>
      );
    } else if (includingAllStatuses && showingVariousArtistsOnly) {
      message = (
        l(`This artist only has unofficial release groups by
           various artists.`) + ' ' +
        l('Showing all release groups for various artists.')
      );
    }
  } else if (wantAllStatuses && !wantVariousArtistsOnly) {
    if (includingAllStatuses && !showingVariousArtistsOnly) {
      message = exp.l(
        `Showing all release groups by this artist.
         {show_official|Show only official release groups instead}, or
         {show_va|show various artists release groups}.`,
        {
          show_official: `${artistLink}?all=0`,
          show_va: `${artistLink}?all=1&va=1`,
        },
      );
    } else if (!existingReleaseGroups) {
      message = l(`This artist does not have any release groups or
                   standalone recordings.`);
    } else if (includingAllStatuses && showingVariousArtistsOnly) {
      message = (
        <>
          {l('This artist only has release groups by various artists.')}
          {' '}
          {exp.l(
            `Showing all release groups for various artists.
             {show_official|Show only official various artists
                            release groups instead}.`,
            {show_official: `${artistLink}?all=0&va=1`},
          )}
        </>
      );
    }
  } else if (!wantAllStatuses && wantVariousArtistsOnly) {
    if (!includingAllStatuses && showingVariousArtistsOnly) {
      message = exp.l(
        `Showing official release groups for various artists.
         {show_all|Show all various artists release groups instead}, or
         {show_non_va|show release groups by this artist}.`,
        {
          show_all: `${artistLink}?all=1&va=1`,
          show_non_va: `${artistLink}?va=0`,
        },
      );
    } else if (!existingReleaseGroups) {
      message = exp.l(
        `This artist does not have any various artists release groups.
         {show_non_va|Show release groups by this artist instead}.`,
        {show_non_va: `${artistLink}?va=0`},
      );
    } else if (includingAllStatuses && showingVariousArtistsOnly) {
      message = (
        <>
          {l(`This artist only has unofficial release groups by
              various artists.`)}
          {' '}
          {exp.l(
            `Showing all release groups for various artists.
             {show_non_va|Show release groups by this artist instead}.`,
            {show_non_va: `${artistLink}?va=0`},
          )}
        </>
      );
    }
  } else if (wantAllStatuses && wantVariousArtistsOnly) {
    if (existingReleaseGroups) {
      message = exp.l(
        `Showing all release groups for various artists.
         {show_official|Show only official various artists
                        release groups instead}, or
         {show_non_va|show release groups by this artist}.`,
        {
          show_non_va: `${artistLink}?all=1&va=0`,
          show_official: `${artistLink}?all=0&va=1`,
        },
      );
    } else {
      message = exp.l(
        `This artist does not have any various artists release groups.
         {show_non_va|Show release groups by this artist instead}.`,
        {show_non_va: `${artistLink}?all=1&va=0`},
      );
    }
  }

  return (
    <ArtistLayout $c={$c} entity={artist} page="index">
      {eligibleForCleanup ? (
        <p className="cleanup">
          {l(`This artist has no relationships, recordings, releases or
              release groups, and will be removed automatically in the next
              few days. If this is not intended, please add more data to
              this artist.`)}
        </p>
      ) : null}

      <Annotation
        annotation={artist.latest_annotation}
        collapse
        entity={artist}
        numberOfRevisions={numberOfRevisions}
      />

      {legalName ? (
        <RelatedArtists title={l('Legal name')}>
          <DescriptiveLink entity={legalName} />
          {legalNameArtistAliases
            ? ' ' + bracketedText(commaOnlyListText(legalNameArtistAliases))
            : null}
        </RelatedArtists>

      ) : legalNameAliases?.length ? (
        <RelatedArtists title={l('Legal name')}>
          {commaOnlyListText(legalNameAliases)}
        </RelatedArtists>
      ) : null}

      {otherIdentities?.length ? (
        <RelatedArtists title={l('Also performs as')}>
          {commaOnlyList(
            otherIdentities.map(a => (
              <DescriptiveLink entity={a} key={a.id} />
            )),
          )}
        </RelatedArtists>
      ) : null}

      <WikipediaExtract
        cachedWikipediaExtract={wikipediaExtract || null}
        entity={artist}
      />

      <h2 className="discography">{l('Discography')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {existingReleaseGroups ? (
        <form
          action={'/release_group/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ReleaseGroupList
              $c={$c}
              checkboxes="add-to-merge"
              releaseGroups={existingReleaseGroups}
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
            <div className="row">
              <FormSubmit label={l('Merge release groups')} />
            </div>
          ) : null}
        </form>
      ) : null}

      {existingRecordings ? (
        <form
          action={'/recording/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <RecordingList
              $c={$c}
              checkboxes="add-to-merge"
              recordings={existingRecordings}
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
            <div className="row">
              <FormSubmit label={l('Add selected recordings for merging')} />
            </div>
          ) : null}
        </form>
      ) : null}

      <p>{message}</p>

      {manifest.js('artist/index.js', {async: 'async'})}
    </ArtistLayout>
  );
};

export default ArtistIndex;
