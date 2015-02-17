package MusicBrainz::Server::Entity::Role::OptionsTree;
use MooseX::Role::Parameterized;

use MooseX::Types::Moose qw( ArrayRef );
use MusicBrainz::Server::Entity::Types;

use List::UtilsBy qw( sort_by );

parameter type => (
    isa => 'Str',
    required => 1,
);

parameter sort_criterion => (
    isa => 'Str',
    default => 'l_name',
);


role {
    my $params = shift;

    has child_order => (
        is => 'rw',
        isa => 'Int',
    );

    has parent_id => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    has parent => (
        is => 'rw',
        isa => $params->type,
    );

    has children => (
        is => 'rw',
        isa => 'ArrayRef[' . $params->type . ']',
        lazy => 1,
        default => sub { [] },
        traits => [ 'Array' ],
        handles => {
            all_children => 'elements',
            add_child => 'push',
            clear_children => 'clear',
        },
    );

    method sorted_children => sub {
        my ($self, $coll) = @_;
        $coll or die "No collator given";
        my $attr = $params->sort_criterion;

        return sort_by {
                            (sprintf "%+012d", $_->child_order) .
                            $coll->getSortKey($_->$attr)
                       }
            $self->all_children;
    };
};

1;

=head1 COPYRIGHT

Copyright (C) 2012, 2014 MetaBrainz Foundation

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
