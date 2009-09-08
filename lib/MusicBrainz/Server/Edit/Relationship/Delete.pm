package MusicBrainz::Server::Edit::Relationship::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_RELATIONSHIP_DELETE }
sub edit_name { "Delete Relationship" }

has '+data' => (
    isa => Dict[
        relationship_id => Int,
        type0 => Str,
        type1 => Str
    ]
);

has 'relationship' => (
    isa => 'Relationship',
    is => 'rw'
);

sub related_entities
{
    my ($self) = @_;

    my $result;
    if ($self->data->{type0} eq $self->data->{type1}) {
        $result = {
            $self->data->{type0} => [ $self->relationship->entity0_id,
                                      $self->relationship->entity1_id ]
        };
    }
    else {
        $result = {
            $self->data->{type0} => [ $self->relationship->entity0_id ],
            $self->data->{type1} => [ $self->relationship->entity1_id ]
        };
    }
    delete $result->{url} if exists $result->{url};
    return $result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->data->{relationship_id});
}

sub initialize
{
    my ($self, %opts) = @_;

    my $relationship = $opts{relationship}
        or die 'You must pass the relationship object';

    $self->relationship($relationship);
    $self->data({
        type0 => $opts{type0},
        type1 => $opts{type1},
        relationship_id => $relationship->id
    });
}

sub accept
{
    my $self = shift;

    $self->c->model('Relationship')->delete(
        $self->data->{type0}, $self->data->{type1},
        $self->data->{relationship_id});
}

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Relationship

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
