package MusicBrainz::Server::Form::User::Preferences;

use HTML::FormHandler::Moose;
use DateTime;
use DateTime::TimeZone;

use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'prefs' );

has_field 'public_ratings' => ( type => 'Boolean' );
has_field 'public_subscriptions' => ( type => 'Boolean' );
has_field 'public_tags' => ( type => 'Boolean' );

has_field 'email_on_no_vote' => ( type => 'Boolean' );
has_field 'email_on_notes' => ( type => 'Boolean' );
has_field 'email_on_vote' => ( type => 'Boolean' );

has_field 'subscribe_to_created_artists' => ( type => 'Boolean' );
has_field 'subscribe_to_created_labels' => ( type => 'Boolean' );

has_field 'show_gravatar' => ( type => 'Boolean' );

has_field 'subscriptions_email_period' => (
    type => 'Select',
    required => 1,
);

has_field 'datetime_format' => (
    type => 'Select',
    required => 1,
);

has_field 'timezone' => (
    type => 'Select',
    required => 1,
);

sub options_datetime_format
{
    my $c = shift->ctx;
    my @allowed_datetime_formats = (
        '%Y-%m-%d %H:%M %Z',
        '%c',
        '%x %X',
        '%X %x',
        '%A %B %e %Y, %H:%M',
        '%d %B %Y %H:%M',
        '%a %b %e %Y, %H:%M',
        '%d %b %Y %H:%M',
        '%d/%m/%Y %H:%M',
        '%m/%d/%Y %H:%M',
        '%d.%m.%Y %H:%M',
        '%m.%d.%Y %H:%M',
    );

    my $now = DateTime->now();
    $now->set_locale($c->stash->{current_language} // 'en');

    my @options;
    foreach my $format (@allowed_datetime_formats) {
        push @options, $format, $now->strftime($format);
    }
    return \@options;
}

sub options_timezone
{
    my @timezones = ('UTC', DateTime::TimeZone->all_names);

    my @options;
    foreach my $timezone (sort @timezones) {
        push @options, $timezone, $timezone;
    }
    return \@options;
}

sub options_subscriptions_email_period
{
    my $options = [
        'daily'     => l('Daily'),
        'weekly'    => l('Weekly'),
        'never'     => l('Never'),
    ];
    return $options;
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
