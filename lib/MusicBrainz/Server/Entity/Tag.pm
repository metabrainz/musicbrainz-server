package MusicBrainz::Server::Entity::Tag;

use Moose;
use MusicBrainz::Server::Constants qw( %ENTITIES );

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'genre_id' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'genre' => (
    is => 'rw',
    isa => 'Maybe[Genre]'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    $json->{name} = $self->name;

    if ($self->genre) {
        $json->{genre} = $self->genre;
    }

    return $json;
};


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Entity::Tag

=head1 ATTRIBUTES

=head2 name

Name of the tag.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
