package MusicBrainz::Server::Entity::EditorLanguage;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Translation qw( l );

has 'editor_id' => (
    is => 'rw',
);

has 'language_id' => (
    is => 'rw',
);

has 'language' => (
    is => 'rw',
);

has 'fluency' => (
    is => 'rw',
);

sub TO_JSON {
    my ($self) = @_;

    return {
        fluency => $self->fluency,
        language => $self->language->TO_JSON,
    };
}

__PACKAGE__->meta->make_immutable;
1;

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
