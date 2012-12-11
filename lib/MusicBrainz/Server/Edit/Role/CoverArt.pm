package MusicBrainz::Server::Edit::Role::CoverArt;
use MooseX::Role::Parameterized;

role
{
    requires qw( cover_art_id release_ids);

    method 'alter_edit_pending' => sub {
        my $self = shift;

        return {
            Release => [ $self->release_ids ],
            Artwork => [ $self->cover_art_id ],
        };
    };
};

no Moose::Role;
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

