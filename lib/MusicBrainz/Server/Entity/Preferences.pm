package MusicBrainz::Server::Entity::Preferences;
use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

has 'public_ratings' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'public_subscriptions' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'public_tags' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'datetime_format' => (
    isa => 'Str',
    default => '%Y-%m-%d %H:%M %Z',
    is => 'rw',
    lazy => 1,
);

has 'timezone' => (
    isa => 'Str',
    default => 'UTC',
    is => 'rw',
    lazy => 1,
);

has [qw(email_on_no_vote email_on_notes email_on_vote)] => (
    isa => 'Bool',
    default => 1,
    is =>'rw',
    lazy => 1
);

has [qw( subscribe_to_created_artists
         subscribe_to_created_labels
         subscribe_to_created_series )] => (
    isa => 'Bool',
    default => 1,
    is =>'rw',
    lazy => 1
);

has 'subscriptions_email_period' => (
    isa => 'Str',
    default => 'daily',
    is => 'rw',
    lazy => 1,
);

has 'show_gravatar' => (
    isa => 'Bool',
    default => 0,
    is => 'rw',
    lazy => 1
);

sub TO_JSON {
    my ($self) = @_;

    return {
        datetime_format => $self->datetime_format,
        show_gravatar => boolean_to_json($self->show_gravatar),
        timezone => $self->timezone,
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
