package MusicBrainz::Server::WebService::Serializer::XML::1::ReleaseEvent;
use Moose;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

sub element { 'event' }

sub attributes {
    my ($self, $entity, $inc, $opts) = @_;
    my @attr;

    my $event = $entity->event;
    my $release = $entity->release;

    push @attr, ( date => $event->date->format )
        unless $event->date->is_empty;

    push @attr, ( country => $event->country->country_code )
        if $event->country && $event->country->country_code;

    push @attr, ( barcode => $release->barcode )
        if $release->barcode;

    push @attr, ( format => $release->combined_format_name )
        if $release->combined_format_name;

    # FIXME - multiple release labels = multiple release events?
    if ($release->labels->[0]) {
        push @attr, ( 'catalog-number' => $release->labels->[0]->catalog_number )
    }

    return @attr;
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my @body;

    my $release = $entity->release;

    # FIXME - multiple release labels = multiple release events?
    if ($release->labels->[0]) {
        push @body, ( serialize_entity( $release->labels->[0]->label) )
            if $inc && $inc->labels;
    }

    return @body;
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
