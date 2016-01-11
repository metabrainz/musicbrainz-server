package MusicBrainz::Server::Entity::URL::MediaWiki;
use Moose::Role;

use MusicBrainz::Server::Filters;

sub page_name {
    my $self = shift;
    return undef if $self->uses_legacy_encoding;

    my ($name) = $self->decoded_local_part =~ m{^/wiki/(.*)$}
        or return undef;
    $name =~ tr/_/ /;

    return $name;
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2016 Ulrich Klauer

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

=cut
