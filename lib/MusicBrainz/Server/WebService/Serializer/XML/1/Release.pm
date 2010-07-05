package MusicBrainz::Server::WebService::Serializer::XML::1::Release;
use Moose;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';

sub element { 'release'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    $self->attributes->{type} = join (" ", $entity->release_group->type->name, $entity->status->name);

    $self->add( $self->gen->title($entity->name) );

    $self->add( $self->gen->text_representation({
        language => uc($entity->language->iso_code_3b),
        script => $entity->script->iso_code,
    }));

    my @asins = grep { $_->link->type->name eq 'amazon asin' } @{$entity->relationships};
    foreach (@asins)
    {
        # FIXME: use aCiD2's coverart/amazon stuff to get the ASIN.
        $self->add( $self->gen->asin("".$2) )
            if ($_->target->url =~
                m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i);
    }

    $self->add( serialize_entity($entity->release_group, undef, { 'gid-only' => 1 }) )
        if ($inc && $inc->release_groups);

    $self->add( $self->gen->track({
        offset => $entity->combined_track_count - 1,
    })) if $entity->combined_track_count;
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

