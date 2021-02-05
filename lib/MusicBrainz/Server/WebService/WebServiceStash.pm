package MusicBrainz::Server::WebService::WebServiceStash;

use Moose;

has '_data' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);


sub store
{
    my ($self, $entity) = @_;

    return ($self->_data->{$entity->entity_type}{$entity->id} //= {});
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
