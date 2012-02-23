package MusicBrainz::Server::Form::Release::AddCoverArt;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( type page ) }

has '+name' => ( default => 'add-cover-art' );

has_field 'filename' => (
    type      => 'Text',
    required  => 1,
);

has_field 'comment' => (
    type      => 'Text',
    required  => 1,
);

has_field 'type' => (
    type      => 'Multiple',
    required  => 1,
);

has_field 'position' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
    default => 1,
);

has_field 'id' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
);

sub options_type  {
    # FIXME: get from database.
    return ("" => "",
            map { $_ => $_ } qw( front back inner booklet sleeve medium obi spine box other ));
}

no Moose;
__PACKAGE__->meta->make_immutable;


=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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
