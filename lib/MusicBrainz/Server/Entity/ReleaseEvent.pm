package MusicBrainz::Server::Entity::ReleaseEvent;
use Moose;

use MusicBrainz::Server::Entity::Types;

has date => (
    is => 'ro',
    isa => 'PartialDate'
);

has country_id => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

has country => (
    is => 'rw',
    isa => 'Maybe[Area]'
);

sub TO_JSON {
    my ($self) = @_;

    return {
        date    => $self->date ? $self->date->TO_JSON : undef,
        country => defined($self->country) ? $self->country->TO_JSON : undef,
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
