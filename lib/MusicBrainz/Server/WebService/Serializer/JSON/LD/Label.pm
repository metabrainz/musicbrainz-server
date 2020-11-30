package MusicBrainz::Server::WebService::Serializer::JSON::LD::Label;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity list_or_single format_date );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area' => { property => 'foundingLocation' };

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicLabel';

    if ($toplevel) {
        my @artists = @{ $entity->relationships_by_link_type_names('recording contract') };
        if (@artists) {
            $ret->{artistSigned} = list_or_single(map { artist_signed($_, $inc, $stash) } @artists);
        }

        if ($stash->store($entity)->{releases}) {
            my $items = $stash->store($entity)->{releases}{items};
            my @releases = map { serialize_entity($_, $inc, $stash) } @$items;
            $ret->{releasePublished} = list_or_single(@releases) if @releases;
        }
    }

    return $ret;
};

sub artist_signed {
    my ($relationship, $inc, $stash) = @_;

    my $ret = {
        '@type' => 'Role',
        artistSigned => serialize_entity($relationship->target, $inc, $stash),
    };

    if (my $begin_date = format_date($relationship->link->begin_date)) {
        $ret->{startDate} = $begin_date;
    }

    if (my $end_date = format_date($relationship->link->end_date)) {
        $ret->{endDate} = $end_date;
    }

    return $ret;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

