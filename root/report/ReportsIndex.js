/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

type Props = {
  +$c: CatalystContextT,
};

const ReportsIndex = ({$c}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Reports')}>
    <div id="content">
      <h1>{l('Reports')}</h1>

      <p>
        {exp.l(
          `If you'd like to participate in the editing process, but do not
           know where to start, the following reports should be useful. These
           reports scour the database looking for data that might require
           fixing, either to comply with the {style|style guidelines}, or in
           other cases where administrative "clean up" tasks are required.`,
          {style: '/doc/Style'},
        )}
      </p>

      <h2>{l('Artists')}</h2>

      <ul>
        <li>
          <a href="/report/ArtistsThatMayBeGroups">
            {l('Artists that may be groups')}
          </a>
        </li>
        <li>
          <a href="/report/ArtistsThatMayBePersons">
            {l('Artists that may be persons')}
          </a>
        </li>
        <li>
          <a href="/report/ArtistsWithNoSubscribers">
            {l('Artists with no subscribers')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateArtists">
            {l('Possibly duplicate artists')}
          </a>
        </li>
        <li>
          <a href="/report/CollaborationRelationships">
            {l('Artists which have collaboration relationships')}
          </a>
        </li>
        <li>
          <a href="/report/PossibleCollaborations">
            {l('Artists which look like collaborations')}
          </a>
        </li>
        <li>
          <a href="/report/ArtistsContainingDisambiguationComments">
            {l('Artists containing disambiguation comments in their name')}
          </a>
        </li>
        <li>
          <a href="/report/DiscogsLinksWithMultipleArtists">
            {l('Discogs URLs linked to multiple artists')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateRelationshipsArtists">
            {l('Artists with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/ArtistsWithMultipleOccurrencesInArtistCredits">
            {l('Artists occurring multiple times in the same artist credit')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipArtists">
            {l('Artists with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsArtists">
            {l('Artists with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/ArtistsDisambiguationSameName">
            {l('Artists with disambiguation the same as the name')}
          </a>
        </li>
      </ul>

      {$c.user?.is_account_admin ? (
        <>
          <h2>{l('Editors')}</h2>

          <ul>
            <li>
              <a href="/report/LimitedEditors">
                {l('Beginner/limited editors')}
              </a>
            </li>
          </ul>
        </>
      ) : null}

      <h2>{l('Events')}</h2>

      <ul>
        <li>
          <a href="/report/DuplicateEvents">
            {l('Possibly duplicate events')}
          </a>
        </li>
        <li>
          <a href="/report/EventSequenceNotInSeries">
            {l('Events which should be part of series or larger event')}
          </a>
        </li>
      </ul>

      <h2>{l('Instruments')}</h2>

      <ul>
        <li>
          <a href="/report/InstrumentsWithoutAnImage">
            {l('Instruments without an image')}
          </a>
        </li>
        <li>
          <a href="/report/InstrumentsWithoutWikidata">
            {l('Instruments without a link to Wikidata')}
          </a>
        </li>
      </ul>

      <h2>{l('Labels')}</h2>

      <ul>
        <li>
          <a href="/report/DiscogsLinksWithMultipleLabels">
            {l('Discogs URLs linked to multiple labels')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateRelationshipsLabels">
            {l('Labels with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipLabels">
            {l('Labels with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsLabels">
            {l('Labels with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/LabelsDisambiguationSameName">
            {l('Labels with disambiguation the same as the name')}
          </a>
        </li>
      </ul>

      <h2>{l('Release groups')}</h2>

      <ul>
        <li>
          <a href="/report/SetInDifferentRG">
            {l('Release groups that might need to be merged')}
          </a>
        </li>
        <li>
          <a href="/report/FeaturingReleaseGroups">
            {l('Release groups with titles containing featuring artists')}
          </a>
        </li>
        <li>
          <a href="/report/DiscogsLinksWithMultipleReleaseGroups">
            {l('Discogs URLs linked to multiple release groups')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateRelationshipsReleaseGroups">
            {l('Release groups with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipReleaseGroups">
            {l('Release groups with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateReleaseGroups">
            {l('Possible duplicate release groups')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsReleaseGroups">
            {l('Release groups with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/ReleaseGroupsWithoutVACredit">
            {l(`Release groups not credited to "Various Artists" but linked
                to VA`)}
          </a>
        </li>
        <li>
          <a href="/report/ReleaseGroupsWithoutVALink">
            {l(`Release groups credited to "Various Artists" but not linked
                to VA`)}
          </a>
        </li>
      </ul>

      <h2>{l('Releases')}</h2>

      <ul>
        <li>
          <a href="/report/ReleasesToConvert">
            {l('Releases which might need converting to "multiple artists"')}
          </a>
        </li>
        <li>
          <a href="/report/NoLanguage">
            {l('Releases without language')}
          </a>
        </li>
        <li>
          <a href="/report/NoScript">
            {l('Releases without script')}
          </a>
        </li>
        <li>
          <a href="/report/BadAmazonURLs">
            {l('Releases which have unexpected Amazon URLs')}
          </a>
        </li>
        <li>
          <a href="/report/MultipleASINs">
            {l('Releases which have multiple ASINs')}
          </a>
        </li>
        <li>
          <a href="/report/MultipleDiscogsLinks">
            {l('Releases which have multiple Discogs links')}
          </a>
        </li>
        <li>
          <a href="/report/ASINsWithMultipleReleases">
            {l('Amazon URLs linked to multiple releases')}
          </a>
        </li>
        <li>
          <a href="/report/DiscogsLinksWithMultipleReleases">
            {l('Discogs URLs linked to multiple releases')}
          </a>
        </li>
        <li>
          <a href="/report/PartOfSetRelationships">
            {l('Releases which have part of set relationships')}
          </a>
        </li>
        <li>
          <a href="/report/SeparateDiscs">
            {l('Discs entered as separate releases')}
          </a>
        </li>
        <li>
          <a href="/report/TracksNamedWithSequence">
            {l('Tracks whose names include their sequence numbers')}
          </a>
        </li>
        <li>
          <a href="/report/TracksWithSequenceIssues">
            {l('Releases with non-sequential track numbers')}
          </a>
        </li>
        <li>
          <a href="/report/SuperfluousDataTracks">
            {l('Releases with superfluous data tracks')}
          </a>
        </li>
        <li>
          <a href="/report/FeaturingReleases">
            {l('Releases with titles containing featuring artists')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasedTooEarly">
            {l('Releases released too early')}
          </a>
        </li>
        <li>
          <a href="/report/SomeFormatsUnset">
            {l(`Releases where some (but not all) mediums have
                no format set`)}
          </a>
        </li>
        <li>
          <a href="/report/CatNoLooksLikeASIN">
            {l('Releases with catalog numbers that look like ASINs')}
          </a>
        </li>
        <li>
          <a href="/report/CatNoLooksLikeLabelCode">
            {l('Releases with catalog numbers that look like Label Codes')}
          </a>
        </li>
        <li>
          <a href="/report/UnlinkedPseudoReleases">
            {l(`Translated/Transliterated Pseudo-Releases not linked to
                an original version`)}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesInCAAWithCoverArtRelationships">
            {l(`Releases in the Cover Art Archive that still have
                cover art relationships`)}
          </a>
        </li>
        <li>
          <a href="/report/CoverArtRelationships">
            {l(`Releases of any sort that still have
                cover art relationships`)}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithCAANoTypes">
            {l(`Releases in the Cover Art Archive where no cover art piece
                has types`)}
          </a>
        </li>
        <li>
          <a href="/report/MediumsWithSequenceIssues">
            {l('Releases with non-sequential mediums')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithUnlikelyLanguageScript">
            {l('Releases with unlikely language/script pairs')}
          </a>
        </li>
        <li>
          <a href="/report/TracksWithoutTimes">
            {l('Releases with unknown track times')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateRelationshipsReleases">
            {l('Releases with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/SingleMediumReleasesWithMediumTitles">
            {l('Releases with a single medium that has a name')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithDownloadRelationships">
            {l('Non-digital releases with download relationships')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipReleases">
            {l('Releases with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsReleases">
            {l('Releases with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithNoMediums">
            {l('Releases with no mediums')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithoutVACredit">
            {l('Releases not credited to "Various Artists" but linked to VA')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesWithoutVALink">
            {l('Releases credited to "Various Artists" but not linked to VA')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesMissingDiscIDs">
            {l('Releases missing disc IDs')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesConflictingDiscIDs">
            {l('Releases with conflicting disc IDs')}
          </a>
        </li>
        <li>
          <a href="/report/ReleaseLabelSameArtist">
            {l('Releases where artist name and label name are the same')}
          </a>
        </li>
        <li>
          <a href="/report/ReleaseRGDifferentName">
            {l('Releases with a different name than their release group')}
          </a>
        </li>
        <li>
          <a href="/report/ReleasesSameBarcode">
            {l('Releases with the same barcode in different release groups')}
          </a>
        </li>
      </ul>

      <h2>{l('Recordings')}</h2>

      <ul>
        <li>
          <a href="/report/RecordingsWithEarliestReleaseRelationships">
            {l('Recordings with earliest release relationships')}
          </a>
        </li>
        <li>
          <a href="/report/FeaturingRecordings">
            {l('Recordings with titles containing featuring artists')}
          </a>
        </li>
        <li>
          <a href="/report/DuplicateRelationshipsRecordings">
            {l('Recordings with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/RecordingsWithVaryingTrackLengths">
            {l('Recordings with varying track times')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipRecordings">
            {l('Recordings with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsRecordings">
            {l('Recordings with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/RecordingsWithoutVACredit">
            {l(`Recordings not credited to "Various Artists" but linked
                to VA`)}
          </a>
        </li>
        <li>
          <a href="/report/RecordingsWithoutVALink">
            {l(`Recordings credited to "Various Artists" but not linked
                to VA`)}
          </a>
        </li>
        {/*
          * MBS-10843: This report has been disabled since the upgrade
          * to PG 12, because its query can no longer execute in under
          * 5 minutes in production.
          */}
        <li style={{display: 'none'}}>
          <a href="/report/RecordingsSameNameDifferentArtistsSameName">
            {l(`Recordings with the same name by different artists
                with the same name`)}
          </a>
        </li>
        <li>
          <a href="/report/RecordingTrackDifferentName">
            {l('Recordings with a different name than their only track')}
          </a>
        </li>
        <li>
          <a href="/report/RecordingsWithFutureDates">
            {l('Recordings with dates in the future')}
          </a>
        </li>
      </ul>

      <h2>{l('Places')}</h2>

      <ul>
        <li>
          <a href="/report/DeprecatedRelationshipPlaces">
            {l('Places with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsPlaces">
            {l('Places with annotations')}
          </a>
        </li>
        <li>
          <a href="/report/PlacesWithoutCoordinates">
            {l('Places without coordinates')}
          </a>
        </li>
      </ul>

      <h2>{l('Series')}</h2>

      <ul>
        <li>
          <a href="/report/AnnotationsSeries">
            {l('Series with annotations')}
          </a>
        </li>
      </ul>

      <h2>{l('Works')}</h2>

      <ul>
        <li>
          <a href="/report/DuplicateRelationshipsWorks">
            {l('Works with possible duplicate relationships')}
          </a>
        </li>
        <li>
          <a href="/report/DeprecatedRelationshipWorks">
            {l('Works with deprecated relationships')}
          </a>
        </li>
        <li>
          <a href="/report/AnnotationsWorks">
            {l('Works with annotations')}
          </a>
        </li>
      </ul>

      <h2>{l('URLs')}</h2>

      <ul>
        <li>
          <a href="/report/DeprecatedRelationshipURLs">
            {l('URLs with deprecated relationships')}
          </a>
        </li>
      </ul>


      <h2>{l('ISRCs')}</h2>

      <ul>
        <li>
          <a href="/report/ISRCsWithManyRecordings">
            {l('ISRCs with multiple recordings')}
          </a>
        </li>
      </ul>

      <h2>{l('ISWCs')}</h2>

      <ul>
        <li>
          <a href="/report/ISWCsWithManyWorks">
            {l('ISWCs with multiple works')}
          </a>
        </li>
      </ul>

      <h2>{l('Disc IDs')}</h2>

      <ul>
        <li>
          <a href="/report/CDTOCDubiousLength">
            {l('Disc IDs with dubious duration')}
          </a>
        </li>
      </ul>
    </div>
  </Layout>
);

export default ReportsIndex;
