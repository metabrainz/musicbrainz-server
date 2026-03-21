package MusicBrainz::Server::Data::WikipediaExtract;
use Moose;
use namespace::autoclean;

use Readonly;
use aliased 'MusicBrainz::Server::Entity::WikipediaExtract';
use aliased 'MusicBrainz::Server::Translation';
use URI::Escape qw( uri_escape_utf8 );
use List::AllUtils qw( first );
use v5.10.1;

with 'MusicBrainz::Server::Data::Role::Context',
     'MusicBrainz::Server::Data::Role::MediaWikiAPI';

# We'll assume interlanguage links don't change much
Readonly my $LANG_CACHE_TIMEOUT => 60 * 60 * 24 * 7; # 1 week
# Extracts will change more often, but
# we still want to keep them around a while
Readonly my $EXTRACT_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_extract
{
    my ($self, $links, $wanted_language, %opts) = @_;
    my $cache_only = $opts{cache_only} // 0;

    my $try_link = sub {
        my ($lang_to_use) = @_;
        return undef unless defined $lang_to_use;
        my $extract = $self->get_extract_by_language(
            $lang_to_use->{title},
            $lang_to_use->{lang},
            cache_only => $cache_only,
        );
        if (defined $extract && !$extract->is_redirect) {
            return $extract;
        }
        return undef;
    };

    my ($first_link) = $links->[0];

    if ($first_link->isa('MusicBrainz::Server::Entity::URL::Wikipedia') && $wanted_language eq $first_link->language) {
        my $extract = $try_link->({ title => $first_link->page_name, lang => $wanted_language });
        return $extract if defined $extract;
    }

    # We didn't by luck get a link in the right language (or it was a redirect)
    my ($languages, $link) = $self->get_available_languages($links, cache_only => $cache_only);

    if (defined $languages && scalar @$languages) {
        my %languages_by_code = map { $_->{lang} => $_ } @$languages;

        # Use desired language if available
        my $extract = $try_link->($languages_by_code{$wanted_language});
        return $extract if defined $extract;

        # Fall back to browser accepted language
        for my $lang (Translation->all_system_languages) {
            my $extract = $try_link->($languages_by_code{$lang});
            return $extract if defined $extract;
        }

        # Fall back to editor known languages
        my $editor = $opts{editor};
        if (defined $editor) {
            my @editor_languages = grep { $_ } map { $_->{language}->{iso_code_1} } @{ $editor->languages };
            for my $lang (@editor_languages) {
                my $extract = $try_link->($languages_by_code{$lang});
                return $extract if defined $extract;
            }
        }

        # Fall back to most frequent languages
        for my $lang (qw(en ja de fr fi it sv es ru pl nl pt et da ko ca cs cy el he hu id lt lv no ro sk sl tr uk vi zh)) {
            my $extract = $try_link->($languages_by_code{$lang});
            return $extract if defined $extract;
        }

        # Fall back to languages that are explicitly linked
        $link = first { $_->isa('MusicBrainz::Server::Entity::URL::Wikipedia') } @$links;
        if (defined $link) {
            my $extract = $try_link->({'title' => $link->page_name, 'lang' => $link->language});
            return $extract if defined $extract;
        }

        # Finally fall back to “whatever we have”
        my $extract = $try_link->($languages->[0]);
        return $extract if defined $extract;
    }

    # We have no language data (probably because we requested cache_only),
    # or all of the fallback options redirected.
    return undef;
}

sub get_extract_by_language
{
    my ($self, $title, $language, %opts) = @_;
    my $url_pattern = 'https://%s.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=1&format=json&redirects=1&titles=%s';
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
            $url_pattern = 'https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&props=sitelinks&ids=%s%s';
            $key = 'sitelinks';
            $callback = \&_wikidata_languages_callback;
        } else {
            $url_pattern = 'https://%s.wikipedia.org/w/api.php?action=query&prop=langlinks&lllimit=max&format=json&redirects=1&titles=%s';
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
            return ($ret, $link);
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
                push @langs, {'lang' => $lang, 'title' => $page};
            }
        }
        return \@langs;
    }
}

sub _wikipedia_languages_callback
{
    my (%opts) = @_;
    my @langs = map { {'lang' => $_->{lang}, 'title' => $_->{'*'}} } @{ $opts{fetched}{content} };
    return \@langs;
}

sub _extract_by_language_callback
{
    my (%opts) = @_;
    my $fetched = $opts{fetched};
    my $content = $fetched->{content};
    if ($content) {
        my $is_redirect = $fetched->{is_redirect} // 0;
        my %props = ( is_redirect => $is_redirect );
        unless ($is_redirect) {
            # No need to store this information in the cache, as redirects
            # aren't displayed.
            $props{title} = $fetched->{title};
            $props{content} = $content =~ s{<p>}{<p><bdi>}gr =~ s{</p>}{</bdi></p>}gr;
            $props{canonical} = $fetched->{canonical};
            $props{language} = $opts{language};
            $props{url} = sprintf 'https://%s.wikipedia.org/wiki/%s',
                                  $opts{language},
                                  uri_escape_utf8($fetched->{title} =~ tr/ /_/r);
        }
        return WikipediaExtract->new(%props);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Ian McEwen
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
