package MusicBrainz::Server::Form::Place;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use List::AllUtils qw( sort_by );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-place' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'address' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1
);

has_field 'area_id'   => ( type => 'Hidden' );
has_field 'area'      => (
    type => '+MusicBrainz::Server::Form::Field::Area'
);

has_field 'coordinates' => (
    type => '+MusicBrainz::Server::Form::Field::Coordinates',
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

sub edit_field_names
{
    return qw( name type_id address area_id comment coordinates period.begin_date period.end_date period.ended );
}

sub options_type_id { select_options_tree(shift->ctx, 'PlaceType') }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
