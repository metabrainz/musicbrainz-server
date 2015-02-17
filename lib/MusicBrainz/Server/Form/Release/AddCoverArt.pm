package MusicBrainz::Server::Form::Release::AddCoverArt;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::CoverArt';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'add-cover-art' );

sub edit_field_names { qw( id ) }

has_field 'id' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
);

has_field 'position' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
    default => 1,
);

has_field 'mime_type' => (
    type      => 'Select',
    required  => 1,
);

sub options_mime_type {
    my @types = map {
        {
            'value' => $_->{mime_type},
            'label' => $_->{suffix},
        }
    } @{ shift->ctx->model('CoverArt')->mime_types };

    return \@types;
}


no Moose;
__PACKAGE__->meta->make_immutable;


=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
