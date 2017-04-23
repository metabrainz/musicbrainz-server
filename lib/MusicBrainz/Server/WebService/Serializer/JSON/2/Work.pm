package MusicBrainz::Server::WebService::Serializer::JSON::2::Work;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    serialize_type
);

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Annotation';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub element { 'work'; }

sub serialize
{
    my ($self, $entity, $inc, $stash) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{iswcs} = [ map { $_->iswc } @{ $entity->iswcs } ];

    $body{attributes} = [
        map {
            my $attr_output = {
                value => $_->value,
                $_->value_gid ? ('value-id' => $_->value_gid) : (),
            };
            serialize_type($attr_output, $_, $inc, $stash, 1);
            $attr_output
        } $entity->all_attributes
    ];

    $body{language} = $entity->language
        ? $entity->language->iso_code_3 // $entity->language->iso_code_2t
        : JSON::null;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011,2012 MetaBrainz Foundation

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

