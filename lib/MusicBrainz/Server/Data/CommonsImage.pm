package MusicBrainz::Server::Data::CommonsImage;
use Moose;
use namespace::autoclean;

use Readonly;
use aliased 'MusicBrainz::Server::Entity::CommonsImage';
use JSON;
use Encode qw( encode );
use URI::Escape qw( uri_escape_utf8 );
use List::AllUtils qw( first );

with 'MusicBrainz::Server::Data::Role::Context';
with 'MusicBrainz::Server::Data::Role::MediaWikiAPI';

Readonly my $COMMONS_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_commons_image
{
    my ($self, $title, %opts) = @_;
    my $cache_only = $opts{cache_only} // 0;
    my $url_pattern = 'https://%s.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&redirects&format=json&iiurlwidth=250&titles=%s';

    return $self->_fetch_cache_or_url($url_pattern, 'imageinfo',
                                      $COMMONS_CACHE_TIMEOUT,
                                      $title, 'commons',
                                      \&_commons_image_callback,
                                      cache_only => $cache_only);
}

sub _commons_image_callback
{
    my (%opts) = @_;
    if ($opts{fetched}{content}) {
        my ($thumb, $image) = map { s/^https?://r } ($opts{fetched}{content}[0]{thumburl}, $opts{fetched}{content}[0]{url});
        return CommonsImage->new( title => $opts{fetched}{title},
                                  thumb_url => $thumb,
                                  image_url => $image);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
