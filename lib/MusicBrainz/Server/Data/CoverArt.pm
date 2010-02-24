package MusicBrainz::Server::Data::CoverArt;
use Moose;

use aliased 'MusicBrainz::Server::CoverArt::Provider::RegularExpression' => 'RegularExpressionProvider';

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
            uri_expression       => 'http://(www\.)?cdbaby\.com/cd/(\w)(\w)(\w*)',
            image_uri_template   => 'http://cdbaby.name/$2/$3/$2$3$4.jpg',
            release_uri_template => 'http://www.cdbaby.com/cd/$2$3$4/from/musicbrainz',
        ),
        RegularExpressionProvider->new(
            name                 => "CD Baby",
            uri_expression       => "http://(www\.)?cdbaby\.name/([a-z0-9])/([a-z0-9])/([A-Za-z0-9]*).jpg",
            image_uri_template   => 'http://cdbaby.name/$2/$3/$4.jpg',
            release_uri_template => 'http://www.cdbaby.com/cd/$4/from/musicbrainz',
        ),
        RegularExpressionProvider->new(
            name               => 'archive.org',
            uri_expression     => '^(.*\.(jpg|jpeg|png|gif))$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name                 => "Jamendo",
            uri_expression       => 'http://www\.jamendo\.com/(\w\w/)?album/(\d+)',
            image_uri_template   => 'http://img.jamendo.com/albums/$2/covers/1.200.jpg',
            release_uri_template => 'http://www.jamendo.com/album/$2',
        ),
        RegularExpressionProvider->new(
            name               => '8bitpeoples.com',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name                 => 'www.ozon.ru',
            uri_expression       => 'http://www.ozon\.ru/context/detail/id/(\d+)',
            image_uri_template   => '',
            release_uri_template => 'http://www.ozon.ru/context/detail/id/$1/?partner=musicbrainz',
        ),
        RegularExpressionProvider->new(
            name                 => 'Encyclopédisque',
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
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name               => 'Universal Poplab',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name               => 'Magnatune',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
        RegularExpressionProvider->new(
            name               => 'Magnatune',
            uri_expression     => '^(.*)$',
            image_uri_template => '$1',
        ),
    ];
}

sub load
{
    my ($self, @releases) = @_;
    for my $release (@release) {
        next unless $release->all_relationships;
        
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
