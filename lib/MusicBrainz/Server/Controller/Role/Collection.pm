package MusicBrainz::Server::Controller::Role::Collection;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;

parameter 'entity_name' => (
    isa => 'Str',
    required => 0
);

parameter 'entity_type' => (
    isa => 'Str',
    required => 1
);

parameter 'method_name' => (
    isa => 'Str',
    required => 0
);

role
{
    my $params = shift;
    my %extra = @_;
    my $entity_type = $params->entity_type;
    my $entity_name = $params->entity_name // $entity_type;
    my $method_name = $params->method_name // 'collections';

    $extra{consumer}->name->config(
        action => {
            $method_name => { Chained => 'load', RequireAuth => undef }
        }
    );

    method _all_collections => sub {
        my ($self, $c) = @_;
        my ($collections) = $c->model('Collection')->find_by({
            entity_id => $c->stash->{$entity_name}->id,
            entity_type => $entity_type,
            show_private => $c->user_exists ? $c->user->id : undef,
        });
        $collections;
    };

    # Stuff that has the side bar and thus needs to display collection information
    method _stash_collections => sub {
        my ($self, $c) = @_;

        my $collections;
        my %containment;
        my $entity_collections = $self->_all_collections($c);
        my %entity_collections_map = map { $_->id => 1 } @$entity_collections;

        if ($c->user_exists) {
            # Make a list of collections and whether this entity is contained in them
            ($collections) = $c->model('Collection')->find_by({
                editor_id => $c->user->id,
                entity_type => $entity_type,
                show_private => $c->user->id,
            });
            foreach my $collection (@$collections) {
                $containment{$collection->id} = 1 if $entity_collections_map{$collection->id};
            }
        }

        $c->stash
          (collections => $collections,
           containment => \%containment,
           all_collections => $entity_collections,
          );
    };

=head2 collections

View a list of collections that this work has been added to.

=cut

    method $method_name => sub {
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

        $c->stash
          (entity_type => $entity_type,
           public_collections => \@public_collections,
           private_collections => $private_collections,
           template => 'entity/collections.tt',
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
