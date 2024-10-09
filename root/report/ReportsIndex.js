/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import {
  isAccountAdmin,
  isRelationshipEditor,
} from '../static/scripts/common/utility/privileges.js';

component ReportsIndexEntry(content: string, reportName: string) {
  return (
    <li>
      <a href={`/report/${reportName}`}>
        {content}
      </a>
    </li>
  );
}

component ReportsIndex() {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <Layout fullWidth title={l_reports('Reports')}>
      <div id="content">
        <h1>{l_reports('Reports')}</h1>

        <p>
          {exp.l_reports(
            `If you'd like to participate in the editing process, but do not
             know where to start, the following reports should be useful.
             These reports scour the database looking for data that might
             require fixing, either to comply with the
             {style|style guidelines}, or in other cases where administrative
             "clean up" tasks are required.`,
            {style: '/doc/Style'},
          )}
        </p>

        <h2>{l_reports('Artists')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Artists that may be groups')}
            reportName="ArtistsThatMayBeGroups"
          />
          <ReportsIndexEntry
            content={l_reports('Artists that may be persons')}
            reportName="ArtistsThatMayBePersons"
          />
          <ReportsIndexEntry
            content={l_reports('Artists with no subscribers')}
            reportName="ArtistsWithNoSubscribers"
          />
          <ReportsIndexEntry
            content={l_reports('Possibly duplicate artists')}
            reportName="DuplicateArtists"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Artists which have collaboration relationships',
            )}
            reportName="CollaborationRelationships"
          />
          <ReportsIndexEntry
            content={l_reports('Artists which look like collaborations')}
            reportName="PossibleCollaborations"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Artists containing disambiguation comments in their name',
            )}
            reportName="ArtistsContainingDisambiguationComments"
          />
          <ReportsIndexEntry
            content={l_reports('Discogs URLs linked to multiple artists')}
            reportName="DiscogsLinksWithMultipleArtists"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Artists with possible duplicate relationships',
            )}
            reportName="DuplicateRelationshipsArtists"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Artists occurring multiple times in the same artist credit',
            )}
            reportName="ArtistsWithMultipleOccurrencesInArtistCredits"
          />
          <ReportsIndexEntry
            content={l_reports('Artists with deprecated relationships')}
            reportName="DeprecatedRelationshipArtists"
          />
          <ReportsIndexEntry
            content={l_reports('Artists with annotations')}
            reportName="AnnotationsArtists"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Artists with disambiguation the same as the name',
            )}
            reportName="ArtistsDisambiguationSameName"
          />
        </ul>

        <h2>{l_reports('Artist credits')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports(
              'Artist credits with dubious trailing join phrases',
            )}
            reportName="ArtistCreditsWithDubiousTrailingPhrases"
          />
        </ul>

        {isAccountAdmin($c.user) ? (
          <>
            <h2>{l_admin('Editors')}</h2>

            <ul>
              <ReportsIndexEntry
                content={l_admin('Beginner/limited editors')}
                reportName="LimitedEditors"
              />
            </ul>
          </>
        ) : null}

        <h2>{l_reports('Events')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Events with annotations')}
            reportName="AnnotationsEvents"
          />
          <ReportsIndexEntry
            content={l_reports('Possibly duplicate events')}
            reportName="DuplicateEvents"
          />
          <ReportsIndexEntry
            content={
              l_reports(
                'Events which should be part of series or larger event',
              )
            }
            reportName="EventSequenceNotInSeries"
          />
        </ul>

        {isRelationshipEditor($c.user) ? (
          <>
            <h2>{l_admin('Instruments')}</h2>

            <ul>
              <ReportsIndexEntry
                content={l_admin('Instruments without an image')}
                reportName="InstrumentsWithoutAnImage"
              />
              <ReportsIndexEntry
                content={l_admin('Instruments without a link to Wikidata')}
                reportName="InstrumentsWithoutWikidata"
              />
            </ul>
          </>
        ) : null}

        <h2>{l_reports('Labels')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Discogs URLs linked to multiple labels')}
            reportName="DiscogsLinksWithMultipleLabels"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Labels with possible duplicate relationships',
            )}
            reportName="DuplicateRelationshipsLabels"
          />
          <ReportsIndexEntry
            content={l_reports('Labels with deprecated relationships')}
            reportName="DeprecatedRelationshipLabels"
          />
          <ReportsIndexEntry
            content={l_reports('Labels with annotations')}
            reportName="AnnotationsLabels"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Labels with disambiguation the same as the name',
            )}
            reportName="LabelsDisambiguationSameName"
          />
        </ul>

        <h2>{l_reports('Release groups')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Release groups that might need to be merged')}
            reportName="SetInDifferentRG"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Release groups with titles containing featuring artists',
            )}
            reportName="FeaturingReleaseGroups"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Discogs URLs linked to multiple release groups',
            )}
            reportName="DiscogsLinksWithMultipleReleaseGroups"
          />
          <ReportsIndexEntry
            content={
              l_reports(
                'Release groups with possible duplicate relationships',
              )
            }
            reportName="DuplicateRelationshipsReleaseGroups"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Release groups with deprecated relationships',
            )}
            reportName="DeprecatedRelationshipReleaseGroups"
          />
          <ReportsIndexEntry
            content={l_reports('Possible duplicate release groups')}
            reportName="DuplicateReleaseGroups"
          />
          <ReportsIndexEntry
            content={l_reports('Release groups with annotations')}
            reportName="AnnotationsReleaseGroups"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Release groups not credited to "Various Artists"
              but linked to VA`,
            )}
            reportName="ReleaseGroupsWithoutVACredit"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Release groups credited to "Various Artists"
              but not linked to VA`,
            )}
            reportName="ReleaseGroupsWithoutVALink"
          />
        </ul>

        <h2>{l_reports('Releases')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports(
              'Releases which might need converting to "multiple artists"',
            )}
            reportName="ReleasesToConvert"
          />
          <ReportsIndexEntry
            content={l_reports('Releases without language')}
            reportName="NoLanguage"
          />
          <ReportsIndexEntry
            content={l_reports('Releases without script')}
            reportName="NoScript"
          />
          <ReportsIndexEntry
            content={l_reports('Releases which have unexpected Amazon URLs')}
            reportName="BadAmazonURLs"
          />
          <ReportsIndexEntry
            content={l_reports('Releases which have multiple ASINs')}
            reportName="MultipleASINs"
          />
          <ReportsIndexEntry
            content={l_reports('Releases which have multiple Discogs links')}
            reportName="MultipleDiscogsLinks"
          />
          <ReportsIndexEntry
            content={l_reports('Amazon URLs linked to multiple releases')}
            reportName="ASINsWithMultipleReleases"
          />
          <ReportsIndexEntry
            content={l_reports('Discogs URLs linked to multiple releases')}
            reportName="DiscogsLinksWithMultipleReleases"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases which have part of set relationships',
            )}
            reportName="PartOfSetRelationships"
          />
          <ReportsIndexEntry
            content={l_reports('Discs entered as separate releases')}
            reportName="SeparateDiscs"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Tracks whose names include their sequence numbers',
            )}
            reportName="TracksNamedWithSequence"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with non-sequential track numbers')}
            reportName="TracksWithSequenceIssues"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with superfluous data tracks')}
            reportName="SuperfluousDataTracks"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with titles containing featuring artists',
            )}
            reportName="FeaturingReleases"
          />
          <ReportsIndexEntry
            content={l_reports('Releases released too early')}
            reportName="ReleasedTooEarly"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Releases where some (but not all) mediums
              have no format set`,
            )}
            reportName="SomeFormatsUnset"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with catalog numbers that look like ASINs',
            )}
            reportName="CatNoLooksLikeASIN"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with catalog numbers that look like ISRCs',
            )}
            reportName="CatNoLooksLikeISRC"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with catalog numbers that look like label codes',
            )}
            reportName="CatNoLooksLikeLabelCode"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Translated/Transliterated Pseudo-Releases
              marked as the original version`,
            )}
            reportName="MislinkedPseudoReleases"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Translated/Transliterated Pseudo-Releases
              not linked to an original version`,
            )}
            reportName="UnlinkedPseudoReleases"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Releases that have Amazon cover art
              but no Cover Art Archive front cover`,
            )}
            reportName="ReleasesWithAmazonCoverArt"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Releases in the Cover Art Archive
              where no cover art piece has types`,
            )}
            reportName="ReleasesWithCAANoTypes"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases without any art in the Cover Art Archive',
            )}
            reportName="ReleasesWithoutCAA"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with mediums named after their position',
            )}
            reportName="MediumsWithOrderInTitle"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with non-sequential mediums')}
            reportName="MediumsWithSequenceIssues"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with unlikely language/script pairs',
            )}
            reportName="ReleasesWithUnlikelyLanguageScript"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with unknown track times')}
            reportName="TracksWithoutTimes"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with possible duplicate relationships',
            )}
            reportName="DuplicateRelationshipsReleases"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with a single medium that has a name',
            )}
            reportName="SingleMediumReleasesWithMediumTitles"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Non-digital releases with digital relationships',
            )}
            reportName="ReleasesWithDownloadRelationships"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Digital releases with mail order relationships',
            )}
            reportName="ReleasesWithMailOrderRelationships"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with deprecated relationships')}
            reportName="DeprecatedRelationshipReleases"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with annotations')}
            reportName="AnnotationsReleases"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with no mediums')}
            reportName="ReleasesWithNoMediums"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with empty mediums')}
            reportName="ReleasesWithEmptyMediums"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases not credited to "Various Artists" but linked to VA',
            )}
            reportName="ReleasesWithoutVACredit"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases credited to "Various Artists" but not linked to VA',
            )}
            reportName="ReleasesWithoutVALink"
          />
          <ReportsIndexEntry
            content={l_reports('Releases missing disc IDs')}
            reportName="ReleasesMissingDiscIDs"
          />
          <ReportsIndexEntry
            content={l_reports('Releases with conflicting disc IDs')}
            reportName="ReleasesConflictingDiscIDs"
          />
          <ReportsIndexEntry
            content={l_reports('Releases that have disc IDs, but shouldn’t')}
            reportName="ShouldNotHaveDiscIDs"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases where artist name and label name are the same',
            )}
            reportName="ReleaseLabelSameArtist"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with a different name than their release group',
            )}
            reportName="ReleaseRGDifferentName"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases with the same barcode in different release groups',
            )}
            reportName="ReleasesSameBarcode"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases on bootleg labels not set to bootleg',
            )}
            reportName="NonBootlegsOnBootlegLabels"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Releases on non-bootleg labels set to bootleg',
            )}
            reportName="BootlegsOnNonBootlegLabels"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Non-broadcast releases with linked show notes',
            )}
            reportName="ShowNotesButNotBroadcast"
          />
          <ReportsIndexEntry
            content={l_reports('Releases marked as having low data quality')}
            reportName="LowDataQualityReleases"
          />
        </ul>

        <h2>{l_reports('Recordings')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports(
              'Recordings with earliest release relationships',
            )}
            reportName="RecordingsWithEarliestReleaseRelationships"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Recordings with titles containing featuring artists',
            )}
            reportName="FeaturingRecordings"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Recordings with possible duplicate relationships',
            )}
            reportName="DuplicateRelationshipsRecordings"
          />
          <ReportsIndexEntry
            content={l_reports('Recordings with varying track times')}
            reportName="RecordingsWithVaryingTrackLengths"
          />
          <ReportsIndexEntry
            content={l_reports('Recordings with deprecated relationships')}
            reportName="DeprecatedRelationshipRecordings"
          />
          <ReportsIndexEntry
            content={l_reports('Recordings with annotations')}
            reportName="AnnotationsRecordings"
          />
          <ReportsIndexEntry
            content={l_reports(
              `Recordings not credited to "Various Artists"
              but linked to VA`,
            )}
            reportName="RecordingsWithoutVACredit"
          />
          <ReportsIndexEntry
            content={l_reports(
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
            *   content={l_reports(
            *     `Recordings with the same name
            *      by different artists with the same name`,
            *   )}
            *   reportName="RecordingsSameNameDifferentArtistsSameName"
            * />
            */}
          <ReportsIndexEntry
            content={l_reports(
              'Recordings with a different name than their only track',
            )}
            reportName="RecordingTrackDifferentName"
          />
          <ReportsIndexEntry
            content={l_reports('Recordings with dates in the future')}
            reportName="RecordingsWithFutureDates"
          />
          <ReportsIndexEntry
            content={l_reports('Video recordings in non-video mediums')}
            reportName="VideosInNonVideoMediums"
          />
          <ReportsIndexEntry
            content={l_reports(
              'Non-video recordings with video relationships',
            )}
            reportName="VideoRelationshipsOnNonVideos"
          />
        </ul>

        <h2>{l_reports('Places')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Places with deprecated relationships')}
            reportName="DeprecatedRelationshipPlaces"
          />
          <ReportsIndexEntry
            content={l_reports('Places with annotations')}
            reportName="AnnotationsPlaces"
          />
          <ReportsIndexEntry
            content={l_reports('Places without coordinates')}
            reportName="PlacesWithoutCoordinates"
          />
        </ul>

        <h2>{lp('Series', 'plural')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Series with annotations')}
            reportName="AnnotationsSeries"
          />
        </ul>

        <h2>{l_reports('Works')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Works with possible duplicate relationships')}
            reportName="DuplicateRelationshipsWorks"
          />
          <ReportsIndexEntry
            content={l_reports('Works with deprecated relationships')}
            reportName="DeprecatedRelationshipWorks"
          />
          <ReportsIndexEntry
            content={l_reports('Works with annotations')}
            reportName="AnnotationsWorks"
          />
          <ReportsIndexEntry
            content={l_reports('Works with the same type as their parent')}
            reportName="WorkSameTypeAsParent"
          />
        </ul>

        <h2>{l_reports('URLs')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('URLs with deprecated relationships')}
            reportName="DeprecatedRelationshipURLs"
          />
          <ReportsIndexEntry
            content={l_reports('URLs linked to multiple entities')}
            reportName="LinksWithMultipleEntities"
          />
          <ReportsIndexEntry
            content={l_reports('Wikidata URLs linked to multiple entities')}
            reportName="WikidataLinksWithMultipleEntities"
          />
        </ul>

        <h2>{l_reports('ISRCs')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('ISRCs with multiple recordings')}
            reportName="ISRCsWithManyRecordings"
          />
        </ul>

        <h2>{l_reports('ISWCs')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('ISWCs with multiple works')}
            reportName="ISWCsWithManyWorks"
          />
        </ul>

        <h2>{l_reports('Disc IDs')}</h2>

        <ul>
          <ReportsIndexEntry
            content={l_reports('Disc IDs with dubious duration')}
            reportName="CDTOCDubiousLength"
          />
          <ReportsIndexEntry
            content={l_reports('Disc IDs attached but not applied')}
            reportName="CDTOCNotApplied"
          />
        </ul>
      </div>
    </Layout>
  );
}

export default ReportsIndex;
