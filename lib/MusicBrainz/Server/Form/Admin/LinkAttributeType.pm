package MusicBrainz::Server::Form::Admin::LinkAttributeType;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit',
     'MusicBrainz::Server::Form::Role::OptionsTree';

sub edit_field_names { qw( parent_id child_order name description creditable free_text ) }

has '+name' => ( default => 'linkattrtype' );

has_field 'parent_id' => (
    type => 'Select',
);

has_field 'child_order' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
);

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255,
);

has_field 'description' => (
    type => 'Text',
);

has_field creditable => (
    type => 'Boolean',
);

has_field free_text => (
    type => 'Boolean',
);

sub options_parent_id
{
    my ($self) = @_;
    return select_options_tree($self->ctx, $self->ctx->stash->{root}, accessor => 'name');
}

sub options_tree_model_name { 'LinkAttributeType' }

after validate => sub {
    my ($self) = @_;

    my $parent = $self->get_parent;
    my $is_root_instrument = defined $parent && (
                             $parent->root_id == $INSTRUMENT_ROOT_ID ||
                             $parent->id == $INSTRUMENT_ROOT_ID);
    if ($is_root_instrument) {
        $self->field('parent_id')->add_error(
            'Cannot add or edit instruments here; use the instrument editing forms instead.',
        );
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
