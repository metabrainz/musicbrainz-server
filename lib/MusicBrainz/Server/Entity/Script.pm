package MusicBrainz::Server::Entity::Script;

use Moose;
use MusicBrainz::Server::Translation::Scripts qw( l );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Name';

sub l_name {
    my $self = shift;
    return l($self->name);
}

has 'iso_code' => (
    is => 'rw',
    isa => 'Str'
);

has 'iso_number' => (
    is => 'rw',
    isa => 'Str'
);

has 'frequency' => (
    is => 'rw',
    isa => 'Int'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{iso_code} = $self->iso_code;
    $json->{iso_number} = $self->iso_number;
    $json->{frequency} = $self->frequency;
    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
