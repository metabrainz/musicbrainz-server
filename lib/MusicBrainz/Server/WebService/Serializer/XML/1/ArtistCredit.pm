package MusicBrainz::Server::WebService::Serializer::XML::1::ArtistCredit;
use Moose;

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

sub element { 'artist'; }

before 'serialize' => sub 
{
    my ($self, $entity, $inc, $opts) = @_;

    if (@{$entity->names} > 1)
    {
        # This artist credit has multiple artists, which cannot be represented
        # properly in /ws/1.  Let's just make the sortname identical to the name
        # for now and omit the ID.

        # FIXME: figure out what was decided at the summit about this.
        # the notes aren't very clear:
        # http://wiki.musicbrainz.org/MusicBrainz_Summit_10/Session_Notes
        
        $self->add( $self->gen->sort_name($entity->name) );
    }
    else
    {
        my $artist = $entity->names->[0]->artist;

        $self->attributes->{id} = $artist->gid;
        $self->add( $self->gen->sort_name($artist->sort_name) );
    }

    $self->add( $self->gen->name($entity->name) );
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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

