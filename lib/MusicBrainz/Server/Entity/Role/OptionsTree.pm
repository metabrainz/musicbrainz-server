package MusicBrainz::Server::Entity::Role::OptionsTree;
use MooseX::Role::Parameterized;

use MooseX::Types::Moose qw( ArrayRef );
use MusicBrainz::Server::Entity::Types;

use List::UtilsBy qw( sort_by );

parameter name => (
    isa => 'Str',
    default => 'name',
);

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

    requires qw( entity_type );

    has $params->name => (
        is => 'rw',
        isa => 'Str',
    );

    has gid => (
        is => 'rw',
        isa => 'Str',
    );

    has description => (
        is => 'rw',
        isa => 'Maybe[Str]',
    );

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

    around TO_JSON => sub {
        my ($orig, $self) = @_;

        my $name = $params->name;

        return {
            %{ $self->$orig },
            $name       => $self->$name,
            gid         => $self->gid,
            parent_id   => $self->parent_id,
            child_order => +$self->child_order,
            description => $self->description,
        };
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012, 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
