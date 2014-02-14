package MusicBrainz::Server::Form::User::WatchPreferences;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Form::Utils qw( select_options );
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

sub options_type_id { select_options(shift->ctx, 'ReleaseGroupType') }
sub options_status_id { select_options(shift->ctx, 'ReleaseStatus') }
sub options_notification_timeframe {
    return [
        1, l('A day'),
        7, l('A week'),
        14, l('2 weeks'),
        31, l('A month')
    ];
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

