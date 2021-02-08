package MusicBrainz::Server::Entity::LinkTypeAttribute;

use Moose;
use MusicBrainz::Server::Entity::Types;

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'LinkAttributeType' };

has 'min' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has 'max' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

sub TO_JSON {
    my ($self) = @_;
    return {
      max => defined $self->max ? 0 + $self->max : undef,
      min => defined $self->min ? 0 + $self->min : undef,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
