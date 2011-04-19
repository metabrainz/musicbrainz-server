package MusicBrainz::Server::WebService::XMLSerializerV1;

use Moose;
use Readonly;
use MusicBrainz::XML::Generator;
use MusicBrainz::Server::WebService::WebServiceIncV1;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serializer serialize_entity);

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

sub mime_type { 'application/xml' }

has 'namespaces' => (
    is      => 'ro',
    isa     => 'HashRef',
    traits  => [ 'Hash' ],
    default => sub { +{} },
    handles => {
        add_namespace => 'set'
    }
);

sub xml_decl_begin {
    my ($self) = @_;
    return '<?xml version="1.0" encoding="UTF-8"?>'.
        '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" ' .
        join(' ', map { 'xmlns:' . $_ . '="' . $self->namespaces->{$_} . '"' } keys %{ $self->namespaces }) .
        '>';
}

sub xml_decl_end { '</metadata>' }

sub output_error
{
    my ($self, $err) = @_;
    return "$err\nFor usage, please see: http://musicbrainz.org/development/mmd\015\012";
}

sub serialize
{
    my ($self, $type, $entity, $inc, $opts) = @_;
    $inc ||= 0;

    my $xml = $self->xml_decl_begin;

    $xml .= serialize_entity($entity, $inc, $opts);

    $xml .= $self->xml_decl_end;
    return $xml;
}

sub xml
{
    my ($self, $xml) = @_;
    return $self->xml_decl_begin . $xml . $self->xml_decl_end;
}

sub serialize_list
{
    my ($self, $type, $entities, $inc, $data) = @_;

    return $self->xml_decl_begin .
        List->new( _element => $type )->serialize($entities, $inc, $data) .
        $self->xml_decl_end;
}


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

