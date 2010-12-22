use strict;
use warnings;
use Test::More;
use Test::Moose;

use_ok 'MusicBrainz::Server::Entity::EditorWatchPreferences';

my $prefs = 'MusicBrainz::Server::Entity::EditorWatchPreferences';
has_attribute_ok($prefs, $_)
    for qw( types statuses notification_timeframe notify_via_email );

done_testing;
