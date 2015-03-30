package MusicBrainz::Server::Controller::Role::Collection;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

parameter 'entity_name' => (
    isa => 'Str',
    required => 1
);

role
{
    my $params = shift;
    my $entity_name = $params->entity_name;

    method _all_collections => sub {
        my ($self, $c) = @_;
        return [ $c->model('Collection')->find_all_by_entity($entity_name, $c->stash->{$entity_name}->id) ];
    };

    # Stuff that has the side bar and thus needs to display collection information
    method _stash_collections => sub {
        my ($self, $c) = @_;

        my @collections;
        my %containment;
        if ($c->user_exists) {
            # Make a list of collections and whether this entity is contained in them
            @collections = $c->model('Collection')->find_all_by_editor($c->user->id, 1, $entity_name);
            foreach my $collection (@collections) {
                $containment{$collection->id} = 1
                  if ($c->model('Collection')->contains_entity($entity_name, $collection->id, $c->stash->{$entity_name}->id));
            }
        }

        $c->stash
          (collections => \@collections,
           containment => \%containment,
           all_collections => $self->_all_collections($c),
          );
    };

    method _collections => sub {
        my ($self, $c) = @_;

        my @public_collections;
        my $private_collections = 0;

        # Keep public collections;
        # count private collection
        foreach my $collection (@{$self->_all_collections($c)}) {
            if ($collection->{'public'} == 1) {
                push(@public_collections, $collection);
            } else {
                $private_collections++;
            }
        }

        $c->model('Editor')->load(@public_collections);

        $c->stash(
           public_collections => \@public_collections,
           private_collections => $private_collections,
        );
    };
};

1;

=head1 COPYRIGHT

Copyright (C) 2015 MetaBrainz Foundation

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
