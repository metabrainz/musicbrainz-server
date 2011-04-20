use strict;
use warnings FATAL => 'all';

use Module::Pluggable::Object;
use lib 't/lib';
use Test::More;
use Test::Routine::Util;

use MusicBrainz::Server::Test qw( commandline_override );

my @classes = qw(
    t::MusicBrainz::Server::Entity::Artist
    t::MusicBrainz::Server::Entity::Annotation
    t::MusicBrainz::Server::Entity::ArtistCredit
    t::MusicBrainz::Server::Entity::AutoEditorElection
    t::MusicBrainz::Server::Entity::CDStub
    t::MusicBrainz::Server::Entity::DurationLookupResult
    t::MusicBrainz::Server::Entity::Editor
    t::MusicBrainz::Server::Entity::EditorWatchPreferences
    t::MusicBrainz::Server::Entity::Label
    t::MusicBrainz::Server::Entity::Language
    t::MusicBrainz::Server::Entity::PartialDate
    t::MusicBrainz::Server::Entity::Rating
    t::MusicBrainz::Server::Entity::Release
    t::MusicBrainz::Server::Entity::Tracklist
    t::MusicBrainz::Server::Entity::Recording
    t::MusicBrainz::Server::Entity::Relationship
    t::MusicBrainz::Server::Entity::ReleaseGroup
    t::MusicBrainz::Server::Entity::SearchResult
    t::MusicBrainz::Server::Entity::URL
    t::MusicBrainz::Server::Entity::WikiDocPage
    t::MusicBrainz::Server::Entity::Work

    t::MusicBrainz::Server::Data::Alias
    t::MusicBrainz::Server::Data::Artist
    t::MusicBrainz::Server::Data::ArtistCredit
    t::MusicBrainz::Server::Data::ArtistType
    t::MusicBrainz::Server::Data::CDStub
    t::MusicBrainz::Server::Data::CDTOC
    t::MusicBrainz::Server::Data::Collate
    t::MusicBrainz::Server::Data::Collection
    t::MusicBrainz::Server::Data::CoreEntityCache
    t::MusicBrainz::Server::Data::Country
    t::MusicBrainz::Server::Data::CoverArt
    t::MusicBrainz::Server::Data::DurationLookup
    t::MusicBrainz::Server::Data::Edit
    t::MusicBrainz::Server::Data::EditNote
    t::MusicBrainz::Server::Data::Editor
    t::MusicBrainz::Server::Data::EditorSubscriptions
    t::MusicBrainz::Server::Data::EntityCache
    t::MusicBrainz::Server::Data::Gender
    t::MusicBrainz::Server::Data::ISRC
    t::MusicBrainz::Server::Data::Label
    t::MusicBrainz::Server::Data::LabelType
    t::MusicBrainz::Server::Data::Language
    t::MusicBrainz::Server::Data::Link
    t::MusicBrainz::Server::Data::LinkAttributeType
    t::MusicBrainz::Server::Data::LinkType
    t::MusicBrainz::Server::Data::Medium
    t::MusicBrainz::Server::Data::MediumFormat
    t::MusicBrainz::Server::Data::PUID
    t::MusicBrainz::Server::Data::Rating
    t::MusicBrainz::Server::Data::Recording
    t::MusicBrainz::Server::Data::Relationship
    t::MusicBrainz::Server::Data::Release
    t::MusicBrainz::Server::Data::ReleaseGroup
    t::MusicBrainz::Server::Data::ReleaseGroupType
    t::MusicBrainz::Server::Data::ReleaseLabel
    t::MusicBrainz::Server::Data::ReleasePackaging
    t::MusicBrainz::Server::Data::ReleaseStatus
    t::MusicBrainz::Server::Data::Script
    t::MusicBrainz::Server::Data::Search
    t::MusicBrainz::Server::Data::Tag
    t::MusicBrainz::Server::Data::Track
    t::MusicBrainz::Server::Data::URL
    t::MusicBrainz::Server::Data::Utils
    t::MusicBrainz::Server::Data::Vote
    t::MusicBrainz::Server::Data::WatchArtist
    t::MusicBrainz::Server::Data::WikiDoc
    t::MusicBrainz::Server::Data::WikiDocIndex
    t::MusicBrainz::Server::Data::Work
    t::MusicBrainz::Server::Data::WorkType
);

@classes = commandline_override ("t::MusicBrainz::Server::", @classes);

plan tests => scalar(@classes);
run_tests($_ => $_) for (@classes);

