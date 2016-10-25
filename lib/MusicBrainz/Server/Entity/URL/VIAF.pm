package MusicBrainz::Server::Entity::URL::VIAF;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

override href_url => sub {
    # Turn the official permalink into what VIAF currently redirects to.
    shift->url->as_string =~
        s{^http://viaf\.org/viaf/([0-9]+)$}{https://viaf.org/viaf/$1/}r;
};

sub pretty_name
{
    my $self = shift;
    return 'VIAF' if $self->uses_legacy_encoding;

    my $name = $self->decoded_local_part;
    $name =~ s{^/viaf/}{};

    $name = "VIAF: $name";

    return $name;
}

sub sidebar_name { shift->pretty_name }

__PACKAGE__->meta->make_immutable;
no Moose;
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
