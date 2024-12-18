package MusicBrainz::Server::Entity::Place;

use Moose;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Alias',
     'MusicBrainz::Server::Entity::Role::Annotation',
     'MusicBrainz::Server::Entity::Role::Area',
     'MusicBrainz::Server::Entity::Role::Comment',
     'MusicBrainz::Server::Entity::Role::DatePeriod',
     'MusicBrainz::Server::Entity::Role::Rating',
     'MusicBrainz::Server::Entity::Role::Relatable',
     'MusicBrainz::Server::Entity::Role::Review',
     'MusicBrainz::Server::Entity::Role::Taggable',
     'MusicBrainz::Server::Entity::Role::Type' => { model => 'PlaceType' };

sub entity_type { 'place' }

has 'address' => (
    is => 'rw',
    isa => 'Str',
);

has 'coordinates' => (
    is => 'rw',
    isa => 'Coordinates',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        address => $self->address,
        area => $self->area ? $self->area->TO_JSON : undef,
        coordinates => $self->coordinates ? $self->coordinates->TO_JSON : undef,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
