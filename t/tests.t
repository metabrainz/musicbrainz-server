use strict;
use warnings FATAL => 'all';

use Module::Pluggable::Object;
use lib 't/lib';
use Test::More;
use Test::Routine::Util;

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
    t::MusicBrainz::Server::Entity::WikiDocPage
    t::MusicBrainz::Server::Entity::Work
);

run_tests($_ => $_) for (@classes);

done_testing;
