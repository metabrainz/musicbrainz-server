package MusicBrainz::Server::Entity::CollectionType;

use Moose;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'CollectionType',
};

sub entity_type { 'collection_type' }

has item_entity_type => (
    is => 'rw',
    isa => 'Str',
);

sub l_name {
    my $self = shift;
    return lp($self->name, 'collection_type')
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
