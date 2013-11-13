package MusicBrainz::Server::Data::CommonsImage;
use Moose;
use namespace::autoclean;

use Readonly;
use aliased 'MusicBrainz::Server::Entity::CommonsImage';
use JSON;
use Encode qw( encode );
use URI::Escape qw( uri_escape_utf8 );
use List::Util qw( first );

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $COMMONS_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_commons_image
{
    my ($self, $title, %opts) = @_;
    my $cache_only = $opts{cache_only} // 0;

    return $self->get_commons_image_by_language($title, "commons", cache_only => $cache_only);
}

sub get_commons_image_by_language
{
    my ($self, $title, %opts) = @_;
    my $url_pattern = "http://%s.wikimedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&redirects&format=json&iiurlwidth=250&titles=%s";
    return $self->_fetch_cache_or_url($url_pattern, 'imageinfo',
                                      $COMMONS_CACHE_TIMEOUT,
                                      $title, "commons",
                                      \&_commons_image_callback,
                                      %opts);
}

sub _fetch_cache_or_url
{
    my ($self, $url_pattern, $json_property, $cache_timeout, $title, $language, $callback, %opts) = @_;
    my $cache_only = $opts{cache_only} // 0;

    my ($cache, $cache_key) = $self->_get_cache_and_key($json_property, $title, $language);

    my $value = $cache->get($cache_key);

    unless (defined $value || $cache_only) {
        my $wp_url = sprintf $url_pattern, $language, uri_escape_utf8($title);

        my $ret = $self->_get_and_process_json($wp_url, $title, $json_property);
        unless (defined $ret) { return undef }

        $value = &$callback(fetched => $ret, language => $language);

        $cache->set($cache_key, $value, $cache_timeout);
    }

    return $value;
}

sub _commons_image_callback
{
    my (%opts) = @_;
    if ($opts{fetched}{content}) {
        return CommonsImage->new( title => $opts{fetched}{title},
                                  thumb_url => $opts{fetched}{content}[0]{thumburl},
                                  page_url => $opts{fetched}{content}[0]{descriptionurl},
                                  image_url => $opts{fetched}{content}[0]{url});
    }
}

sub _get_cache_and_key
{
    my ($self, $prefix, $title, $language) = @_;
    $title = uri_escape_utf8($title);
    my $cache = $self->c->cache;
    my $cache_key = "wp:$prefix:$title:$language";

    return ($cache, $cache_key)
}

sub _get_and_process_json
{
    my ($self, $url, $title, $property) = @_;

    # request JSON
    my $response = $self->c->lwp->get($url);
    unless ($response->is_success) {
        return undef;
    }

    # decode JSON
    my $content = decode_json(encode("utf-8", $response->content));
    unless ($content->{query}) { return undef }
    else { $content = $content->{query} }

    # save title as passed in
    my $noncanonical = $title;

    # capitalization normalizations
    my $normalized = first { $_->{from} eq $title } @{ $content->{normalized} } if $content->{normalized};
    if ($normalized) {
        $title = $normalized->{to};
    }

    # wiki redirects
    my $redirects = first { $_->{from} eq $title } @{ $content->{redirects} } if $content->{redirects};
    if ($redirects) {
        $title = $redirects->{to};
    }

    # pull out the correct page, though there should only be one
    my $ret = first { $_->{title} eq $title } values %{ $content->{pages} };
    unless ($ret && $ret->{$property}) { $ret->{$property} = undef; }

    return {content => $ret->{$property}, title => $noncanonical, canonical => $title}
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
