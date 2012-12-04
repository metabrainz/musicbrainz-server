package MusicBrainz::Server::Form::CoverArt;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

sub edit_field_names { qw( comment type_id position ) }

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'type_id' => (
    type      => 'Select',
    multiple  => 1,
);

sub options_type_id {
    my $self = shift;

    my %types_by_name = map { $_->name => $_ } $self->ctx->model('CoverArtType')->get_all ();

    my $front = delete $types_by_name{Front};
    my $back = delete $types_by_name{Back};
    my $other = delete $types_by_name{Other};

    my $ret = [
        map {
            defined $_ ? ($_->id => $_->l_name) : ()
        } ($front, $back, values %types_by_name, $other) ];

    return $ret;
};

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
