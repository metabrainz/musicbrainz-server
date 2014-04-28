package MusicBrainz::Server::Form::Place;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';
with 'MusicBrainz::Server::Form::Role::ExternalLinks';

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
    not_nullable => 1
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

sub options_type_id { select_options(shift->ctx, 'PlaceType') }

sub dupe_model { shift->ctx->model('Place') }

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
