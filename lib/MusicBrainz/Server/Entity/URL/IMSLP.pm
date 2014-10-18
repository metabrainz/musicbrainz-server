package MusicBrainz::Server::Entity::URL::IMSLP;

use Moose;
use MusicBrainz::Server::Filters;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

=method pretty_name

Attempt to display IMSLP URLs as 'imslp: Page Name'. This will only
happen if the URL can be decoded from utf-8. If not, the entire URL is used.

=cut

sub pretty_name
{
    my $self = shift;
    return $self->url->as_string unless defined($self->utf8_decoded);

    my $name = MusicBrainz::Server::Filters::uri_decode($self->url->path);
    $name =~ s{^/wiki/}{};
    $name =~ s{_}{ }g;

    $name = "imslp: $name";

    return $name;
}

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^https?://(?:www.)?imslp.org/wiki/Category(.*)$}i) {
        return "IMSLP";
    } else {
        return "Score at IMSLP";
    }
}

=method show_in_sidebar

IMSLP URLs are only show in the sidebar if the URL can be decoded from utf-8

=cut

sub show_in_sidebar { defined(shift->utf8_decoded) }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

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
