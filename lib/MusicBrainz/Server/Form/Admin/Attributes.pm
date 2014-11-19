package MusicBrainz::Server::Form::Admin::Attributes;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( parent_id child_order name description year has_discids free_text ) }

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

sub options_parent_id {
    my ($self, $model) = @_;
    return select_options_tree($self->ctx, $self->ctx->stash->{model}, accessor => 'name');
}

1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
