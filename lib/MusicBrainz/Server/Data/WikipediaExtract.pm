package MusicBrainz::Server::Data::WikipediaExtract;
use Moose;
use namespace::autoclean;

use Readonly;
use aliased 'MusicBrainz::Server::Entity::WikipediaExtract';
use JSON;
use Encode qw( encode );
use List::Util qw( first );

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $LANG_CACHE_TIMEOUT => 60 * 60; # 1 hour
Readonly my $EXTRACT_CACHE_TIMEOUT => 60 * 60 * 24; # 1 day

sub get_extract
{
    my ($self, $title, $wanted_language, $wikipedia_language) = @_;

    # trim country codes (at least for now)
    $wanted_language =~ s/[_-][A-Za-z]+$//;

    if ($wanted_language eq $wikipedia_language) {
        return $self->get_extract_by_language($title, $wikipedia_language);
    }

    my $languages = $self->get_available_languages($title, $wikipedia_language);

    my $lang_wanted = first { $_->{lang} eq $wanted_language } @$languages;
    my $english = first { $_->{lang} eq 'en' } @$languages;

    if ($lang_wanted) {
        return $self->get_extract_by_language($lang_wanted->{'*'}, $lang_wanted->{lang});
    } elsif ($wikipedia_language eq 'en') {
        return $self->get_extract_by_language($title, $wikipedia_language);
    } elsif ($english) {
        return $self->get_extract_by_language($english->{'*'}, $english->{lang});
    } else {
        return $self->get_extract_by_language($title, $wikipedia_language);
    }
}

sub get_extract_by_language
{
    my ($self, $title, $language) = @_;

    my ($cache, $cache_key) = $self->_get_cache_and_key('wp:extract', $title, $language);

    my $extract = $cache->get($cache_key);

    unless (defined $extract) {
        my $wp_url = sprintf "http://%s.wikipedia.org/w/api.php?action=query&prop=extracts&exsentences=100&format=json&redirects=1&titles=%s", $language, $title;

        my $ret = $self->_get_and_process_json($wp_url, $title, 'extract');
        unless ($ret) { return undef }

        $extract = WikipediaExtract->new( title => $ret->{title},
                                          content => $ret->{content},
                                          canonical => $ret->{canonical},
                                          language => $language );

        $cache->set($cache_key, $extract, $EXTRACT_CACHE_TIMEOUT);
    }

    return $extract;
}

sub get_available_languages
{
    my ($self, $title, $base_language) = @_;

    my ($cache, $cache_key) = $self->_get_cache_and_key('wp:languages', $title, $base_language);

    my $options = $cache->get($cache_key);

    unless (defined $options) {
        my $languages_url = sprintf "http://%s.wikipedia.org/w/api.php?action=query&prop=langlinks&lllimit=500&format=json&redirects=1&titles=%s", $base_language, $title;

        my $ret = $self->_get_and_process_json($languages_url, $title, 'langlinks');
        unless ($ret) { return undef }

        $options = $ret->{content};
        $cache->set($cache_key, $options, $LANG_CACHE_TIMEOUT);
    }
    return $options;
}

sub _get_cache_and_key
{
    my ($self, $prefix, $title, $language) = @_;
    my $cache = $self->c->cache($prefix);
    my $cache_key = "$prefix:$title:$language";

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
    my $normalized = first { $_->{from} eq $title } $content->{normalized} if $content->{normalized};
    if ($normalized) {
        $title = $normalized->{to};
    }

    # wiki redirects
    my $redirects = first { $_->{from} eq $title } $content->{redirects} if $content->{redirects};
    if ($redirects) {
        $title = $redirects->{to};
    }

    # pull out the correct page, though there should only be one
    my $ret = first { $_->{title} eq $title } values $content->{pages};
    unless ($ret && $ret->{$property}) { return undef; }

    return {content => $ret->{$property}, title => $noncanonical, canonical => $title}
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
