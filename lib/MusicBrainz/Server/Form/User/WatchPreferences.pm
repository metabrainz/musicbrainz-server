package MusicBrainz::Server::Form::User::WatchPreferences;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use DateTime;
use DateTime::TimeZone;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'watch-prefs' );

has_field 'type_id' => (
    type => 'Select',
    multiple => 1,
);

has_field 'status_id' => (
    type => 'Select',
    multiple => 1,
);

has_field 'notify_via_email' => (
    type => 'Checkbox',
);

has_field 'notification_timeframe' => (
    type => 'Select',
    required => 1
);

sub options_type_id { select_options_tree(shift->ctx, 'ReleaseGroupType') }
sub options_status_id { select_options_tree(shift->ctx, 'ReleaseStatus') }
sub options_notification_timeframe {
    return [
        1, l('A day'),
        7, l('A week'),
        14, l('2 weeks'),
        31, l('A month')
    ];
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

