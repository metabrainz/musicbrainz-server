package MusicBrainz::Server::Form::Admin::Attributes;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use MusicBrainz::Server::Constants qw( entities_with );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

sub edit_field_names { qw( parent_id child_order name description year has_discids free_text item_entity_type ) }

has '+name' => ( default => 'attr' );

has_field 'parent_id' => (
    type => 'Select',
);

has_field 'child_order' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    default => 0,
);

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'description' => (
    type => 'Text',
);

has_field 'year' => (
    type => 'Text',
);

has_field 'has_discids' => (
    type => 'Boolean',
);

has_field 'free_text' => (
    type => 'Boolean',
);

has_field 'item_entity_type' => (
    type => 'Select',
);

sub options_parent_id {
    my ($self, $model) = @_;
    return select_options_tree($self->ctx, $self->ctx->stash->{model}, accessor => 'name');
}

sub options_item_entity_type {
    my ($self, $model) = @_;
    my $entity_type = $self->ctx->stash->{model} eq 'SeriesType' ? 'series' : 'collections';
    return map { $_ => $_ } sort { $a cmp $b } entities_with($entity_type);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
