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
import {
  isAccountAdmin,
  isRelationshipEditor,
} from '../static/scripts/common/utility/privileges';

type ReportsIndexEntryProps = {
  +content: string,
  +reportName: string,
};

type Props = {
  +$c: CatalystContextT,
};

const ReportsIndexEntry = ({
  content,
  reportName,
}: ReportsIndexEntryProps): React.Element<'li'> => (
  <li>
    <a href={`/report/${reportName}`}>
      {content}
    </a>
  </li>

);

const ReportsIndex = ({$c}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Reports')}>
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
        <ReportsIndexEntry
          content={l('Artists that may be groups')}
          reportName="ArtistsThatMayBeGroups"
        />
        <ReportsIndexEntry
          content={l('Artists that may be persons')}
          reportName="ArtistsThatMayBePersons"
        />
        <ReportsIndexEntry
          content={l('Artists with no subscribers')}
          reportName="ArtistsWithNoSubscribers"
        />
        <ReportsIndexEntry
          content={l('Possibly duplicate artists')}
          reportName="DuplicateArtists"
        />
        <ReportsIndexEntry
          content={l('Artists which have collaboration relationships')}
          reportName="CollaborationRelationships"
        />
        <ReportsIndexEntry
          content={l('Artists which look like collaborations')}
          reportName="PossibleCollaborations"
        />
        <ReportsIndexEntry
          content={l(
            'Artists containing disambiguation comments in their name',
          )}
          reportName="ArtistsContainingDisambiguationComments"
        />
        <ReportsIndexEntry
          content={l('Discogs URLs linked to multiple artists')}
          reportName="DiscogsLinksWithMultipleArtists"
        />
        <ReportsIndexEntry
          content={l('Artists with possible duplicate relationships')}
          reportName="DuplicateRelationshipsArtists"
        />
        <ReportsIndexEntry
          content={l(
            'Artists occurring multiple times in the same artist credit',
          )}
          reportName="ArtistsWithMultipleOccurrencesInArtistCredits"
        />
        <ReportsIndexEntry
          content={l('Artists with deprecated relationships')}
          reportName="DeprecatedRelationshipArtists"
        />
        <ReportsIndexEntry
          content={l('Artists with annotations')}
          reportName="AnnotationsArtists"
        />
        <ReportsIndexEntry
          content={l('Artists with disambiguation the same as the name')}
          reportName="ArtistsDisambiguationSameName"
        />
      </ul>

      <h2>{l('Artist credits')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Artist credits with dubious trailing join phrases')}
          reportName="ArtistCreditsWithDubiousTrailingPhrases"
        />
      </ul>

      {isAccountAdmin($c.user) ? (
        <>
          <h2>{l('Editors')}</h2>

          <ul>
            <ReportsIndexEntry
              content={l('Beginner/limited editors')}
              reportName="LimitedEditors"
            />
          </ul>
        </>
      ) : null}

      <h2>{l('Events')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Possibly duplicate events')}
          reportName="DuplicateEvents"
        />
        <ReportsIndexEntry
          content={l('Events which should be part of series or larger event')}
          reportName="EventSequenceNotInSeries"
        />
      </ul>

      {isRelationshipEditor($c.user) ? (
        <>
          <h2>{l('Instruments')}</h2>

          <ul>
            <ReportsIndexEntry
              content={l('Instruments without an image')}
              reportName="InstrumentsWithoutAnImage"
            />
            <ReportsIndexEntry
              content={l('Instruments without a link to Wikidata')}
              reportName="InstrumentsWithoutWikidata"
            />
          </ul>
        </>
      ) : null}

      <h2>{l('Labels')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Discogs URLs linked to multiple labels')}
          reportName="DiscogsLinksWithMultipleLabels"
        />
        <ReportsIndexEntry
          content={l('Labels with possible duplicate relationships')}
          reportName="DuplicateRelationshipsLabels"
        />
        <ReportsIndexEntry
          content={l('Labels with deprecated relationships')}
          reportName="DeprecatedRelationshipLabels"
        />
        <ReportsIndexEntry
          content={l('Labels with annotations')}
          reportName="AnnotationsLabels"
        />
        <ReportsIndexEntry
          content={l('Labels with disambiguation the same as the name')}
          reportName="LabelsDisambiguationSameName"
        />
      </ul>

      <h2>{l('Release groups')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Release groups that might need to be merged')}
          reportName="SetInDifferentRG"
        />
        <ReportsIndexEntry
          content={l(
            'Release groups with titles containing featuring artists',
          )}
          reportName="FeaturingReleaseGroups"
        />
        <ReportsIndexEntry
          content={l('Discogs URLs linked to multiple release groups')}
          reportName="DiscogsLinksWithMultipleReleaseGroups"
        />
        <ReportsIndexEntry
          content={l('Release groups with possible duplicate relationships')}
          reportName="DuplicateRelationshipsReleaseGroups"
        />
        <ReportsIndexEntry
          content={l('Release groups with deprecated relationships')}
          reportName="DeprecatedRelationshipReleaseGroups"
        />
        <ReportsIndexEntry
          content={l('Possible duplicate release groups')}
          reportName="DuplicateReleaseGroups"
        />
        <ReportsIndexEntry
          content={l('Release groups with annotations')}
          reportName="AnnotationsReleaseGroups"
        />
        <ReportsIndexEntry
          content={l(
            `Release groups not credited to "Various Artists"
             but linked to VA`,
          )}
          reportName="ReleaseGroupsWithoutVACredit"
        />
        <ReportsIndexEntry
          content={l(
            `Release groups credited to "Various Artists"
             but not linked to VA`,
          )}
          reportName="ReleaseGroupsWithoutVALink"
        />
      </ul>

      <h2>{l('Releases')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l(
            'Releases which might need converting to "multiple artists"',
          )}
          reportName="ReleasesToConvert"
        />
        <ReportsIndexEntry
          content={l('Releases without language')}
          reportName="NoLanguage"
        />
        <ReportsIndexEntry
          content={l('Releases without script')}
          reportName="NoScript"
        />
        <ReportsIndexEntry
          content={l('Releases which have unexpected Amazon URLs')}
          reportName="BadAmazonURLs"
        />
        <ReportsIndexEntry
          content={l('Releases which have multiple ASINs')}
          reportName="MultipleASINs"
        />
        <ReportsIndexEntry
          content={l('Releases which have multiple Discogs links')}
          reportName="MultipleDiscogsLinks"
        />
        <ReportsIndexEntry
          content={l('Amazon URLs linked to multiple releases')}
          reportName="ASINsWithMultipleReleases"
        />
        <ReportsIndexEntry
          content={l('Discogs URLs linked to multiple releases')}
          reportName="DiscogsLinksWithMultipleReleases"
        />
        <ReportsIndexEntry
          content={l('Releases which have part of set relationships')}
          reportName="PartOfSetRelationships"
        />
        <ReportsIndexEntry
          content={l('Discs entered as separate releases')}
          reportName="SeparateDiscs"
        />
        <ReportsIndexEntry
          content={l('Tracks whose names include their sequence numbers')}
          reportName="TracksNamedWithSequence"
        />
        <ReportsIndexEntry
          content={l('Releases with non-sequential track numbers')}
          reportName="TracksWithSequenceIssues"
        />
        <ReportsIndexEntry
          content={l('Releases with superfluous data tracks')}
          reportName="SuperfluousDataTracks"
        />
        <ReportsIndexEntry
          content={l('Releases with titles containing featuring artists')}
          reportName="FeaturingReleases"
        />
        <ReportsIndexEntry
          content={l('Releases released too early')}
          reportName="ReleasedTooEarly"
        />
        <ReportsIndexEntry
          content={l(
            `Releases where some (but not all) mediums
             have no format set`,
          )}
          reportName="SomeFormatsUnset"
        />
        <ReportsIndexEntry
          content={l('Releases with catalog numbers that look like ASINs')}
          reportName="CatNoLooksLikeASIN"
        />
        <ReportsIndexEntry
          content={l('Releases with catalog numbers that look like ISRCs')}
          reportName="CatNoLooksLikeISRC"
        />
        <ReportsIndexEntry
          content={l(
            'Releases with catalog numbers that look like Label Codes',
          )}
          reportName="CatNoLooksLikeLabelCode"
        />
        <ReportsIndexEntry
          content={l(
            `Translated/Transliterated Pseudo-Releases
             marked as the original version`,
          )}
          reportName="MislinkedPseudoReleases"
        />
        <ReportsIndexEntry
          content={l(
            `Translated/Transliterated Pseudo-Releases
             not linked to an original version`,
          )}
          reportName="UnlinkedPseudoReleases"
        />
        <ReportsIndexEntry
          content={l(
            `Releases in the Cover Art Archive
             that still have cover art relationships`,
          )}
          reportName="ReleasesInCAAWithCoverArtRelationships"
        />
        <ReportsIndexEntry
          content={l(
            `Releases of any sort
             that still have cover art relationships`,
          )}
          reportName="CoverArtRelationships"
        />
        <ReportsIndexEntry
          content={l(
            `Releases in the Cover Art Archive
             where no cover art piece has types`,
          )}
          reportName="ReleasesWithCAANoTypes"
        />
        <ReportsIndexEntry
          content={l('Releases with non-sequential mediums')}
          reportName="MediumsWithSequenceIssues"
        />
        <ReportsIndexEntry
          content={l('Releases with unlikely language/script pairs')}
          reportName="ReleasesWithUnlikelyLanguageScript"
        />
        <ReportsIndexEntry
          content={l('Releases with unknown track times')}
          reportName="TracksWithoutTimes"
        />
        <ReportsIndexEntry
          content={l('Releases with possible duplicate relationships')}
          reportName="DuplicateRelationshipsReleases"
        />
        <ReportsIndexEntry
          content={l('Releases with a single medium that has a name')}
          reportName="SingleMediumReleasesWithMediumTitles"
        />
        <ReportsIndexEntry
          content={l('Non-digital releases with digital relationships')}
          reportName="ReleasesWithDownloadRelationships"
        />
        <ReportsIndexEntry
          content={l('Releases with deprecated relationships')}
          reportName="DeprecatedRelationshipReleases"
        />
        <ReportsIndexEntry
          content={l('Releases with annotations')}
          reportName="AnnotationsReleases"
        />
        <ReportsIndexEntry
          content={l('Releases with no mediums')}
          reportName="ReleasesWithNoMediums"
        />
        <ReportsIndexEntry
          content={l('Releases with empty mediums')}
          reportName="ReleasesWithEmptyMediums"
        />
        <ReportsIndexEntry
          content={l(
            'Releases not credited to "Various Artists" but linked to VA',
          )}
          reportName="ReleasesWithoutVACredit"
        />
        <ReportsIndexEntry
          content={l(
            'Releases credited to "Various Artists" but not linked to VA',
          )}
          reportName="ReleasesWithoutVALink"
        />
        <ReportsIndexEntry
          content={l('Releases missing disc IDs')}
          reportName="ReleasesMissingDiscIDs"
        />
        <ReportsIndexEntry
          content={l('Releases with conflicting disc IDs')}
          reportName="ReleasesConflictingDiscIDs"
        />
        <ReportsIndexEntry
          content={l('Releases that have disc IDs, but shouldn’t')}
          reportName="ShouldNotHaveDiscIDs"
        />
        <ReportsIndexEntry
          content={l(
            'Releases where artist name and label name are the same',
          )}
          reportName="ReleaseLabelSameArtist"
        />
        <ReportsIndexEntry
          content={l(
            'Releases with a different name than their release group',
          )}
          reportName="ReleaseRGDifferentName"
        />
        <ReportsIndexEntry
          content={l(
            'Releases with the same barcode in different release groups',
          )}
          reportName="ReleasesSameBarcode"
        />
      </ul>

      <h2>{l('Recordings')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Recordings with earliest release relationships')}
          reportName="RecordingsWithEarliestReleaseRelationships"
        />
        <ReportsIndexEntry
          content={l('Recordings with titles containing featuring artists')}
          reportName="FeaturingRecordings"
        />
        <ReportsIndexEntry
          content={l('Recordings with possible duplicate relationships')}
          reportName="DuplicateRelationshipsRecordings"
        />
        <ReportsIndexEntry
          content={l('Recordings with varying track times')}
          reportName="RecordingsWithVaryingTrackLengths"
        />
        <ReportsIndexEntry
          content={l('Recordings with deprecated relationships')}
          reportName="DeprecatedRelationshipRecordings"
        />
        <ReportsIndexEntry
          content={l('Recordings with annotations')}
          reportName="AnnotationsRecordings"
        />
        <ReportsIndexEntry
          content={l(
            `Recordings not credited to "Various Artists"
             but linked to VA`,
          )}
          reportName="RecordingsWithoutVACredit"
        />
        <ReportsIndexEntry
          content={l(
            `Recordings credited to "Various Artists"
             but not linked to VA`,
          )}
          reportName="RecordingsWithoutVALink"
        />
        {/*
          * MBS-10843: This report has been disabled since the upgrade
          * to PG 12, because its query can no longer execute in under
          * 5 minutes in production.
          *
          * <ReportsIndexEntry
          *   content={l(
          *     `Recordings with the same name
          *      by different artists with the same name`,
          *   )}
          *   reportName="RecordingsSameNameDifferentArtistsSameName"
          * />
          */}
        <ReportsIndexEntry
          content={l(
            'Recordings with a different name than their only track',
          )}
          reportName="RecordingTrackDifferentName"
        />
        <ReportsIndexEntry
          content={l('Recordings with dates in the future')}
          reportName="RecordingsWithFutureDates"
        />
      </ul>

      <h2>{l('Places')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Places with deprecated relationships')}
          reportName="DeprecatedRelationshipPlaces"
        />
        <ReportsIndexEntry
          content={l('Places with annotations')}
          reportName="AnnotationsPlaces"
        />
        <ReportsIndexEntry
          content={l('Places without coordinates')}
          reportName="PlacesWithoutCoordinates"
        />
      </ul>

      <h2>{l('Series')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Series with annotations')}
          reportName="AnnotationsSeries"
        />
      </ul>

      <h2>{l('Works')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Works with possible duplicate relationships')}
          reportName="DuplicateRelationshipsWorks"
        />
        <ReportsIndexEntry
          content={l('Works with deprecated relationships')}
          reportName="DeprecatedRelationshipWorks"
        />
        <ReportsIndexEntry
          content={l('Works with annotations')}
          reportName="AnnotationsWorks"
        />
        <ReportsIndexEntry
          content={l('Works with the same type as their parent')}
          reportName="WorkSameTypeAsParent"
        />
      </ul>

      <h2>{l('URLs')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('URLs with deprecated relationships')}
          reportName="DeprecatedRelationshipURLs"
        />
        <ReportsIndexEntry
          content={l('URLs linked to multiple entities')}
          reportName="LinksWithMultipleEntities"
        />
        <ReportsIndexEntry
          content={l('Wikidata URLs linked to multiple entities')}
          reportName="WikidataLinksWithMultipleEntities"
        />
      </ul>

      <h2>{l('ISRCs')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('ISRCs with multiple recordings')}
          reportName="ISRCsWithManyRecordings"
        />
      </ul>

      <h2>{l('ISWCs')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('ISWCs with multiple works')}
          reportName="ISWCsWithManyWorks"
        />
      </ul>

      <h2>{l('Disc IDs')}</h2>

      <ul>
        <ReportsIndexEntry
          content={l('Disc IDs with dubious duration')}
          reportName="CDTOCDubiousLength"
        />
        <ReportsIndexEntry
          content={l('Disc IDs attached but not applied')}
          reportName="CDTOCNotApplied"
        />
      </ul>
    </div>
  </Layout>
);

export default ReportsIndex;
