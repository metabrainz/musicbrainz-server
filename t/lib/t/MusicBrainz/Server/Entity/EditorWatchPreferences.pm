package t::MusicBrainz::Server::Entity::EditorWatchPreferences;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;

use MusicBrainz::Server::Entity::EditorWatchPreferences;

test all => sub {

my $prefs = 'MusicBrainz::Server::Entity::EditorWatchPreferences';
has_attribute_ok($prefs, $_)
    for qw( types statuses notification_timeframe notify_via_email );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
