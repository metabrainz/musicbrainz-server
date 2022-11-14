package MusicBrainz::Server::Entity::Recording;

use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw(
    add_linked_entity
    to_json_array
    to_json_object
);
use List::AllUtils qw( uniq_by );

extends 'MusicBrainz::Server::Entity::CentralEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Review';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::ArtistCredit';

sub entity_type { 'recording' }

has 'track_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'track' => (
    is => 'rw',
    isa => 'Track'
);

has 'length' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'video' => (
    is => 'rw',
    isa => 'Bool',
);

has 'isrcs' => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        add_isrc => 'push',
        all_isrcs => 'elements',
        clear_isrcs => 'clear',
    }
);

has 'first_release_date' => (
    is => 'rw',
    isa => 'Maybe[PartialDate]',
);

sub related_works {
    my $self = shift;
    return uniq_by { $_->id }
    map {
        $_->entity1
    } grep {
        $_->link && $_->link->type && $_->link->type->entity1_type eq 'work'
    } $self->all_relationships;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my @related_works = $self->related_works;
    add_linked_entity('work', $_->id, $_) for @related_works;

    return {
        %{ $self->$orig },
        isrcs   => to_json_array($self->isrcs),
        length  => $self->length,
        video   => boolean_to_json($self->video),
        related_works => [map { $_->id } @related_works],
        first_release_date => to_json_object($self->first_release_date),
    };
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
