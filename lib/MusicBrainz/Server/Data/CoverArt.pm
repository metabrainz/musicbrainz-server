package MusicBrainz::Server::Data::CoverArt;
use Moose;

use aliased 'MusicBrainz::Server::CoverArt::Provider::RegularExpression'  => 'RegularExpressionProvider';
use aliased 'MusicBrainz::Server::CoverArt::Provider::WebService::Amazon' => 'AmazonProvider';

has 'providers' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy_build => 1
);

sub _build_providers {
    my ($self) = @_;

    return [
        RegularExpressionProvider->new(
            name                 => "CD Baby",
            domain               => 'cdbaby.com',
            uri_expression       => 'http://(www\.)?cdbaby\.com/cd/(\w)(\w)(\w*)',
            image_uri_template   => 'http://cdbaby.name/$2/$3/$2$3$4.jpg',
            release_uri_template => 'http://www.cdbaby.com/cd/$2$3$4/from/musicbrainz',
        ),
        RegularExpressionProvider->new(
            name                 => "CD Baby",
            domain               => 'cdbaby.name',
            uri_expression       => "http://(www\.)?cdbaby\.name/([a-z0-9])/([a-z0-9])/([A-Za-z0-9]*).jpg",
            image_uri_template   => 'http://cdbaby.name/$2/$3/$4.jpg',
            release_uri_template => 'http://www.cdbaby.com/cd/$4/from/musicbrainz',
        ),
        RegularExpressionProvider->new(
            name               => 'archive.org',
            domain             => 'archive.org',
            uri_expression     => '^(.*\.(jpg|jpeg|png|gif))$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name                 => "Jamendo",
            domain               => 'www.jamendo.com',
            uri_expression       => 'http://www\.jamendo\.com/(\w\w/)?album/(\d+)',
            image_uri_template   => 'http://img.jamendo.com/albums/$2/covers/1.200.jpg',
            release_uri_template => 'http://www.jamendo.com/album/$2',
        ),
        RegularExpressionProvider->new(
            name               => '8bitpeoples.com',
            domain             => '8bitpeoples.com',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name                 => 'www.ozon.ru',
            domain               => 'www.ozon.ru',
            uri_expression       => 'http://www.ozon\.ru/context/detail/id/(\d+)',
            image_uri_template   => '',
            release_uri_template => 'http://www.ozon.ru/context/detail/id/$1/?partner=musicbrainz',
        ),
        RegularExpressionProvider->new(
            name                 => 'Encyclopédisque',
            domain               => 'encyclopedisque.fr',
            uri_expression       => 'http://www.encyclopedisque.fr/images/imgdb/(thumb250|main)/(\d+).jpg',
            image_uri_template   => 'http://www.encyclopedisque.fr/images/imgdb/thumb250/$2.jpg',
            release_uri_template => 'http://www.encyclopedisque.fr/',
        ),
        RegularExpressionProvider->new(
            name                 => 'Manj\'Disc',
            domain               => 'www.mange-disque.tv',
            uri_expression       => 'http://(www\.)?mange-disque\.tv/(fstb/tn_md_|fs/md_|info_disque\.php3\?dis_code=)(\d+)(\.jpg)?',
            image_uri_template   => 'http://www.mange-disque.tv/fs/md_$3.jpg',
            release_uri_template => 'http://www.mange-disque.tv/info_disque.php3?dis_code=$3',
        ),
        RegularExpressionProvider->new(
            name               => 'Thastrom',
            domain             => 'www.thastrom.se',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name               => 'Universal Poplab',
            domain             => 'www.universalpoplab.com',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name               => 'Magnatune',
            domain             => 'magnatune.com',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        AmazonProvider->new(
            name => 'Amazon',
        )
    ];
}

has '_handled_link_types' => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1,
    traits     => [ 'Hash' ],
    handles    => {
        can_parse     => 'exists',
        get_providers => 'get'
    }
);

sub _build__handled_link_types {
    my $self = shift;
    my %types;
    for my $provider (@{ $self->providers }) {
        $types{$provider->link_type_name} ||= [];
        push @{ $types{$provider->link_type_name} }, $provider;
    }

    return \%types;
}

sub load
{
    my ($self, @releases) = @_;
    for my $release (@releases) {
        for my $relationship ($release->all_relationships) {
            my $lt_name = $relationship->link->type->name;
            next unless $self->can_parse($lt_name);

            my $cover_url = $relationship->target->url;

            my $cover_art;
            for my $provider (@{ $self->get_providers($lt_name) }) {
                next unless $provider->handles($cover_url);
                $cover_art = $provider->lookup_cover_art($cover_url)
                    and last;
            }

            # Couldn't parse cover art from this relationship, try another
            next if !defined $cover_art;

            # Loaded fine, finish parsing this release and move onto the next
            $release->cover_art($cover_art);
            last;
        }
    }
}

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
