package MusicBrainz::Server::ReportFactory;
use strict;
use warnings;

use DBDefs;
use MusicBrainz::Server::PagedReport;

my @all = qw(
    ASINsWithMultipleReleases
    AnnotationsArtists
    AnnotationsEvents
    AnnotationsLabels
    AnnotationsPlaces
    AnnotationsRecordings
    AnnotationsReleases
    AnnotationsReleaseGroups
    AnnotationsSeries
    AnnotationsWorks
    ArtistCreditsWithDubiousTrailingPhrases
    ArtistsContainingDisambiguationComments
    ArtistsDisambiguationSameName
    ArtistsWithMultipleOccurrencesInArtistCredits
    ArtistsThatMayBeGroups
    ArtistsThatMayBePersons
    ArtistsWithNoSubscribers
    BadAmazonURLs
    CatNoLooksLikeASIN
    CatNoLooksLikeISRC
    CatNoLooksLikeLabelCode
    CDTOCDubiousLength
    CDTOCNotApplied
    CollaborationRelationships
    DeprecatedRelationshipArtists
    DeprecatedRelationshipLabels
    DeprecatedRelationshipPlaces
    DeprecatedRelationshipRecordings
    DeprecatedRelationshipReleases
    DeprecatedRelationshipReleaseGroups
    DeprecatedRelationshipURLs
    DeprecatedRelationshipWorks
    DiscogsLinksWithMultipleArtists
    DiscogsLinksWithMultipleLabels
    DiscogsLinksWithMultipleReleaseGroups
    DiscogsLinksWithMultipleReleases
    DuplicateArtists
    DuplicateEvents
    DuplicateRelationshipsArtists
    DuplicateRelationshipsReleaseGroups
    DuplicateRelationshipsReleases
    DuplicateRelationshipsRecordings
    DuplicateRelationshipsWorks
    DuplicateRelationshipsLabels
    DuplicateReleaseGroups
    EventSequenceNotInSeries
    FeaturingRecordings
    FeaturingReleaseGroups
    FeaturingReleases
    InstrumentsWithoutAnImage
    InstrumentsWithoutWikidata
    ISRCsWithManyRecordings
    ISWCsWithManyWorks
    LabelsDisambiguationSameName
    LimitedEditors
    LinksWithMultipleEntities
    MediumsWithOrderInTitle
    MediumsWithSequenceIssues
    MislinkedPseudoReleases
    MultipleASINs
    MultipleDiscogsLinks
    NoLanguage
    NonBootlegsOnBootlegLabels
    NoScript
    PartOfSetRelationships
    PlacesWithoutCoordinates
    PossibleCollaborations
    RecordingsWithoutVACredit
    RecordingsWithoutVALink
    RecordingsWithEarliestReleaseRelationships
    RecordingsWithVaryingTrackLengths
    RecordingTrackDifferentName
    RecordingsWithFutureDates
    ReleasedTooEarly
    ReleaseGroupsWithoutVACredit
    ReleaseGroupsWithoutVALink
    ReleaseLabelSameArtist
    ReleaseRGDifferentName
    ReleasesSameBarcode
    ReleasesToConvert
    ReleasesWithAmazonCoverArt
    ReleasesWithCAANoTypes
    ReleasesWithDownloadRelationships
    ReleasesWithEmptyMediums
    ReleasesWithMailOrderRelationships
    ReleasesWithNoMediums
    ReleasesWithoutVACredit
    ReleasesWithoutVALink
    ReleasesWithUnlikelyLanguageScript
    ReleasesMissingDiscIDs
    ReleasesConflictingDiscIDs
    SeparateDiscs
    SetInDifferentRG
    ShouldNotHaveDiscIDs
    SingleMediumReleasesWithMediumTitles
    SomeFormatsUnset
    SuperfluousDataTracks
    TracksNamedWithSequence
    TracksWithoutTimes
    TracksWithSequenceIssues
    UnlinkedPseudoReleases
    VideosInNonVideoMediums
    WikidataLinksWithMultipleEntities
    WorkSameTypeAsParent
);

use MusicBrainz::Server::Report::ASINsWithMultipleReleases;
use MusicBrainz::Server::Report::AnnotationReports;
use MusicBrainz::Server::Report::ArtistCreditsWithDubiousTrailingPhrases;
use MusicBrainz::Server::Report::ArtistsContainingDisambiguationComments;
use MusicBrainz::Server::Report::ArtistsDisambiguationSameName;
use MusicBrainz::Server::Report::ArtistsThatMayBeGroups;
use MusicBrainz::Server::Report::ArtistsThatMayBePersons;
use MusicBrainz::Server::Report::ArtistsWithMultipleOccurrencesInArtistCredits;
use MusicBrainz::Server::Report::ArtistsWithNoSubscribers;
use MusicBrainz::Server::Report::BadAmazonURLs;
use MusicBrainz::Server::Report::CatNoLooksLikeASIN;
use MusicBrainz::Server::Report::CatNoLooksLikeISRC;
use MusicBrainz::Server::Report::CatNoLooksLikeLabelCode;
use MusicBrainz::Server::Report::CDTOCDubiousLength;
use MusicBrainz::Server::Report::CDTOCNotApplied;
use MusicBrainz::Server::Report::CollaborationRelationships;
use MusicBrainz::Server::Report::DeprecatedRelationshipArtists;
use MusicBrainz::Server::Report::DeprecatedRelationshipLabels;
use MusicBrainz::Server::Report::DeprecatedRelationshipPlaces;
use MusicBrainz::Server::Report::DeprecatedRelationshipRecordings;
use MusicBrainz::Server::Report::DeprecatedRelationshipReleases;
use MusicBrainz::Server::Report::DeprecatedRelationshipReleaseGroups;
use MusicBrainz::Server::Report::DeprecatedRelationshipURLs;
use MusicBrainz::Server::Report::DeprecatedRelationshipWorks;
use MusicBrainz::Server::Report::DiscogsLinksWithMultipleArtists;
use MusicBrainz::Server::Report::DiscogsLinksWithMultipleLabels;
use MusicBrainz::Server::Report::DiscogsLinksWithMultipleReleaseGroups;
use MusicBrainz::Server::Report::DiscogsLinksWithMultipleReleases;
use MusicBrainz::Server::Report::DuplicateArtists;
use MusicBrainz::Server::Report::DuplicateEvents;
use MusicBrainz::Server::Report::DuplicateRelationshipsArtists;
use MusicBrainz::Server::Report::DuplicateRelationshipsReleaseGroups;
use MusicBrainz::Server::Report::DuplicateRelationshipsReleases;
use MusicBrainz::Server::Report::DuplicateRelationshipsRecordings;
use MusicBrainz::Server::Report::DuplicateRelationshipsWorks;
use MusicBrainz::Server::Report::DuplicateRelationshipsLabels;
use MusicBrainz::Server::Report::DuplicateReleaseGroups;
use MusicBrainz::Server::Report::EventSequenceNotInSeries;
use MusicBrainz::Server::Report::FeaturingRecordings;
use MusicBrainz::Server::Report::FeaturingReleaseGroups;
use MusicBrainz::Server::Report::FeaturingReleases;
use MusicBrainz::Server::Report::InstrumentsWithoutAnImage;
use MusicBrainz::Server::Report::InstrumentsWithoutWikidata;
use MusicBrainz::Server::Report::ISRCsWithManyRecordings;
use MusicBrainz::Server::Report::ISWCsWithManyWorks;
use MusicBrainz::Server::Report::LabelsDisambiguationSameName;
use MusicBrainz::Server::Report::LimitedEditors;
use MusicBrainz::Server::Report::LinksWithMultipleEntities;
use MusicBrainz::Server::Report::MediumsWithOrderInTitle;
use MusicBrainz::Server::Report::MediumsWithSequenceIssues;
use MusicBrainz::Server::Report::MislinkedPseudoReleases;
use MusicBrainz::Server::Report::MultipleASINs;
use MusicBrainz::Server::Report::MultipleDiscogsLinks;
use MusicBrainz::Server::Report::NoLanguage;
use MusicBrainz::Server::Report::NonBootlegsOnBootlegLabels;
use MusicBrainz::Server::Report::NoScript;
use MusicBrainz::Server::Report::PartOfSetRelationships;
use MusicBrainz::Server::Report::PlacesWithoutCoordinates;
use MusicBrainz::Server::Report::PossibleCollaborations;
use MusicBrainz::Server::Report::RecordingsWithoutVACredit;
use MusicBrainz::Server::Report::RecordingsWithoutVALink;
use MusicBrainz::Server::Report::RecordingsWithEarliestReleaseRelationships;
use MusicBrainz::Server::Report::RecordingsWithVaryingTrackLengths;
#use MusicBrainz::Server::Report::RecordingsSameNameDifferentArtistsSameName;
use MusicBrainz::Server::Report::RecordingTrackDifferentName;
use MusicBrainz::Server::Report::RecordingsWithFutureDates;
use MusicBrainz::Server::Report::ReleasedTooEarly;
use MusicBrainz::Server::Report::ReleaseGroupsWithoutVACredit;
use MusicBrainz::Server::Report::ReleaseGroupsWithoutVALink;
use MusicBrainz::Server::Report::ReleaseLabelSameArtist;
use MusicBrainz::Server::Report::ReleaseRGDifferentName;
use MusicBrainz::Server::Report::ReleasesToConvert;
use MusicBrainz::Server::Report::ReleasesSameBarcode;
use MusicBrainz::Server::Report::ReleasesWithAmazonCoverArt;
use MusicBrainz::Server::Report::ReleasesWithCAANoTypes;
use MusicBrainz::Server::Report::ReleasesWithDownloadRelationships;
use MusicBrainz::Server::Report::ReleasesWithEmptyMediums;
use MusicBrainz::Server::Report::ReleasesWithMailOrderRelationships;
use MusicBrainz::Server::Report::ReleasesWithNoMediums;
use MusicBrainz::Server::Report::ReleasesWithoutVACredit;
use MusicBrainz::Server::Report::ReleasesWithoutVALink;
use MusicBrainz::Server::Report::ReleasesWithUnlikelyLanguageScript;
use MusicBrainz::Server::Report::ReleasesMissingDiscIDs;
use MusicBrainz::Server::Report::ReleasesConflictingDiscIDs;
use MusicBrainz::Server::Report::SeparateDiscs;
use MusicBrainz::Server::Report::SetInDifferentRG;
use MusicBrainz::Server::Report::ShouldNotHaveDiscIDs;
use MusicBrainz::Server::Report::SingleMediumReleasesWithMediumTitles;
use MusicBrainz::Server::Report::SomeFormatsUnset;
use MusicBrainz::Server::Report::SuperfluousDataTracks;
use MusicBrainz::Server::Report::TracksNamedWithSequence;
use MusicBrainz::Server::Report::TracksWithoutTimes;
use MusicBrainz::Server::Report::TracksWithSequenceIssues;
use MusicBrainz::Server::Report::UnlinkedPseudoReleases;
use MusicBrainz::Server::Report::VideosInNonVideoMediums;
use MusicBrainz::Server::Report::WikidataLinksWithMultipleEntities;
use MusicBrainz::Server::Report::WorkSameTypeAsParent;

my %all = map { $_ => 1 } @all;

sub all_report_names
{
    return @all;
}

sub create_report
{
    my ($class, $name, $c) = @_;

    return undef
        unless $all{$name};

    my $report_class = "MusicBrainz::Server::Report::$name";
    return $report_class->new( c => $c );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
