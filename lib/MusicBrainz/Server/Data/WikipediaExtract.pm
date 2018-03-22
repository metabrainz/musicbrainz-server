package MusicBrainz::Server::Data::WikipediaExtract;
use Moose;
use namespace::autoclean;

use Readonly;
use aliased 'MusicBrainz::Server::Entity::WikipediaExtract';
use aliased 'MusicBrainz::Server::Translation';
use JSON;
use Encode qw( encode );
use URI::Escape qw( uri_escape_utf8 );
use List::Util qw( first );
use v5.10.1;

with 'MusicBrainz::Server::Data::Role::Context';
with 'MusicBrainz::Server::Data::Role::MediaWikiAPI';

# We'll assume interlanguage links don't change much
Readonly my $LANG_CACHE_TIMEOUT => 60 * 60 * 24 * 7; # 1 week
# Extracts will change more often, but
# we still want to keep them around a while
Readonly my $EXTRACT_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_extract
{
    my ($self, $links, $wanted_language, %opts) = @_;
    my $cache_only = $opts{cache_only} // 0;

    my ($first_link) = $links->[0];

    if ($first_link->isa('MusicBrainz::Server::Entity::URL::Wikipedia') && $wanted_language eq $first_link->language) {
        return $self->get_extract_by_language($first_link->page_name, $first_link->language, cache_only => $cache_only);
    }

    # We didn't by luck get a link in the right language
    my ($languages, $link) = $self->get_available_languages($links, cache_only => $cache_only);

    if (defined $languages && scalar @$languages) {
        # Use desired language if available
        my $lang_to_use = first { $_->{lang} eq $wanted_language } @$languages;

        # Fall back to browser accepted languages
        if (!$lang_to_use) {
            for my $lang (Translation->all_system_languages) {
                $lang_to_use = first { $_->{lang} eq $lang } @$languages;
                last if $lang_to_use;
            }
        }

        # Fall back to editor known languages
        if (!$lang_to_use) {
            my $editor = $opts{editor};
            if (defined $editor) {
                my @editor_languages = grep { $_ } map { $_->{language}->{iso_code_1} } @{ $editor->languages };
                for my $lang (@editor_languages) {
                    $lang_to_use = first { $_->{lang} eq $lang } @$languages;
                    last if $lang_to_use;
                }
            }
        }

        # Fall back to most frequent languages
        if (!$lang_to_use) {
            for my $lang (qw(en ja de fr fi it sv es ru pl nl pt et da ko ca cs cy el he hu id lt lv no ro sk sl tr uk vi zh)) {
                $lang_to_use = first { $_->{lang} eq $lang } @$languages;
                last if $lang_to_use;
            }
        }

        # Fall back to languages that are explicitly linked
        if (!$lang_to_use) {
            $link = first { $_->isa('MusicBrainz::Server::Entity::URL::Wikipedia') } @$links;
            $lang_to_use = {'title' => $link->page_name, 'lang' => $link->language} if defined $link;
        }

        # Finally fall back to “whatever we have”
        if (!$lang_to_use) {
            $lang_to_use = $languages->[0];
        }

        return $self->get_extract_by_language($lang_to_use->{title}, $lang_to_use->{lang}, cache_only => $cache_only);
    } else {
        # We have no language data, probably because we requested cache_only
        return undef;
    }
}

sub get_extract_by_language
{
    my ($self, $title, $language, %opts) = @_;
    my $url_pattern = "https://%s.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=1&format=json&redirects=1&titles=%s";
    return $self->_fetch_cache_or_url($url_pattern, 'extract',
                                      $EXTRACT_CACHE_TIMEOUT,
                                      $title, $language,
                                      \&_extract_by_language_callback,
                                      %opts);
}

sub get_available_languages
{
    my ($self, $links, %opts) = @_;
    for my $link (@$links) {
        my ($url_pattern, $key, $callback, $language, $ret);
        if ($link->isa('MusicBrainz::Server::Entity::URL::Wikidata')) {
            $url_pattern = "https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&props=sitelinks&ids=%s%s";
            $key = 'sitelinks';
            $callback = \&_wikidata_languages_callback;
        } else {
            $url_pattern = "https://%s.wikipedia.org/w/api.php?action=query&prop=langlinks&lllimit=max&format=json&redirects=1&titles=%s";
            $key = 'langlinks';
            $callback = \&_wikipedia_languages_callback;
            $language = $link->language;
        }
        $ret = $self->_fetch_cache_or_url($url_pattern, $key,
                                             $LANG_CACHE_TIMEOUT,
                                             $link->page_name, $language,
                                             $callback,
                                             %opts);
        if (ref $ret eq 'ARRAY') {
            if ($link->isa('MusicBrainz::Server::Entity::URL::Wikipedia')) {
                push @$ret, {lang => $link->language, title => $link->page_name};
            }
            return ($ret, $link)
        }
    }
    return (undef, undef);
}

sub _wikidata_languages_callback
{
    my (%opts) = @_;
    if ($opts{fetched}{content}{sitelinks}) {
        my @langs;
        for my $wiki (keys %{ $opts{fetched}{content}{sitelinks} }) {
            if ($wiki =~ /wiki$/ and $wiki ne 'commonswiki') {
                my $lang = $wiki =~ s/wiki$//r;
                my $page = $opts{fetched}{content}{sitelinks}{$wiki}{title};
                push @langs, {"lang" => $lang, "title" => $page}
            }
        }
        return \@langs;
    }
}

sub _wikipedia_languages_callback
{
    my (%opts) = @_;
    my @langs = map { {"lang" => $_->{lang}, "title" => $_->{"*"}} } @{ $opts{fetched}{content} };
    return \@langs;
}

sub _extract_by_language_callback
{
    my (%opts) = @_;
    if ($opts{fetched}{content}) {
        return WikipediaExtract->new( title => $opts{fetched}{title},
                                      content => $opts{fetched}{content},
                                      canonical => $opts{fetched}{canonical},
                                      language => $opts{language},
                                      url => sprintf "https://%s.wikipedia.org/wiki/%s",
                                                     $opts{language},
                                                     uri_escape_utf8($opts{fetched}{title} =~ tr/ /_/r)
        );
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Ian McEwen
Copyright (C) 2012 MetaBrainz Foundation

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
