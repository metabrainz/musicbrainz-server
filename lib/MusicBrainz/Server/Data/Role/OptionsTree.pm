package MusicBrainz::Server::Data::Role::OptionsTree;
use MooseX::Role::Parameterized;
use namespace::autoclean;

# This is not used by the role directly,
# but passed to Role::SelectAll below
parameter 'order_by' => (
    isa => 'ArrayRef',
    default => sub { ['id'] },
);

role {
    my $p = shift;
    my $order_by = $p->order_by;

    with 'MusicBrainz::Server::Data::Role::Context',
         'MusicBrainz::Server::Data::Role::SelectAll' => {
            order_by => $order_by,
         };

    sub get_tree {
        my ($self, $filter, $root_id) = @_;

        my @objects;

        $filter ||= sub { return 1 };

        my %id_to_obj = map {
            my $obj = $_;
            push @objects, $obj;
            $obj->id => $obj;
        } grep {
            $filter->($_);
        } $self->get_all;

        my $root = $self->_entity_class->new;

        foreach my $obj (@objects) {
            my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
            $parent->add_child($obj);
        }

        return $id_to_obj{$root_id} if defined $root_id;

        return $root;
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
