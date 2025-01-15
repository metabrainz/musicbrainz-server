package MusicBrainz::Server::Form::Role::OptionsTree;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

requires qw( options_tree_model_name );

sub options_tree_model {
    my $self = shift;
    $self->ctx->model($self->options_tree_model_name);
}

sub get_parent {
    my $self = shift;
    my $parent_id = $self->field('parent_id')->value;
    my $parent = $parent_id
        ? $self->options_tree_model->get_by_id($parent_id)
        : undef;
    return $parent;
}

after validate => sub {
    my ($self) = @_;

    my $parent = $self->get_parent;
    my $own_id = defined $self->init_object
        ? $self->init_object->{id}
        : undef;

    if (defined $parent && defined $own_id) {
        my $is_self_parent = $parent->id == $own_id;
        if ($is_self_parent) {
            $self->field('parent_id')->add_error(
                'A type cannot be its own parent.',
            );
        } else {
            my $is_own_child =
                $self->options_tree_model->is_child($own_id, $parent->id);
            if ($is_own_child) {
                $self->field('parent_id')->add_error(
                    'A type cannot be a child of its own child.',
                );
            }
        }
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
