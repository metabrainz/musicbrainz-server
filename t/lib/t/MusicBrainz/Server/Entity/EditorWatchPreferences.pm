package t::MusicBrainz::Server::Entity::EditorWatchPreferences;
use Test::Routine;
use Test::Moose;

use MusicBrainz::Server::Entity::EditorWatchPreferences;

test all => sub {

my $prefs = 'MusicBrainz::Server::Entity::EditorWatchPreferences';
has_attribute_ok($prefs, $_)
    for qw( types statuses notification_timeframe notify_via_email );

};

1;
