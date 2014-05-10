package MusicBrainz::Server::Form::Series;
use HTML::FormHandler::Moose;
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::SeriesOrderingType;
use MusicBrainz::Server::Entity::SeriesType;
use MusicBrainz::Server::Form::Utils qw( select_options_tree build_options_tree );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-series' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'type_id' => (
    type => 'Select',
    required => 1,
);

has_field 'ordering_attribute_id' => (
    type => 'Select',
    required => 1,
);

has_field 'ordering_type_id' => (
    type => 'Select',
    required => 1,
);

sub edit_field_names {
    return qw( name comment type_id ordering_attribute_id ordering_type_id );
}

sub options_type_id {
    select_options_tree(shift->ctx, 'SeriesType');
}

sub options_ordering_attribute_id {
    my ($self) = @_;

    my $root = $self->ctx->model('LinkAttributeType')->text_attribute_types;
    my @roots = $root->all_children;

    return [
        map { build_options_tree($_, 'l_name', '') }
        # $roots[0] is the non-selectable "ordering" attribute
        $roots[0]->all_children
    ];
}

sub options_ordering_type_id {
    select_options_tree(shift->ctx, 'SeriesOrderingType');
}

sub dupe_model {
    shift->ctx->model('Series');
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
