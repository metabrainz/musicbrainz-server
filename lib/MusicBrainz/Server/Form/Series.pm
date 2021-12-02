package MusicBrainz::Server::Form::Series;
use HTML::FormHandler::Moose;
use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Entity::SeriesOrderingType;
use MusicBrainz::Server::Entity::SeriesType;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
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

has_field 'ordering_type_id' => (
    type => 'Select',
    required => 1,
);

sub edit_field_names {
    return qw( name comment type_id ordering_type_id );
}

sub options_type_id {
    select_options_tree(shift->ctx, 'SeriesType');
}

sub options_ordering_type_id {
    select_options_tree(shift->ctx, 'SeriesOrderingType');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
