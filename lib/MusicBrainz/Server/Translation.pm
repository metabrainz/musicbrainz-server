package MusicBrainz::Server::Translation;
use MooseX::Singleton;

use Cwd qw(abs_path);
use DBDefs;
use DateTime::Locale;
use I18N::LangTags ();
use I18N::LangTags::Detect;
use List::AllUtils qw( any sort_by );
use Locale::Messages qw( bindtextdomain LC_MESSAGES );
use Locale::Util qw( web_set_locale );
use POSIX qw( setlocale );
use Text::Balanced qw( extract_bracketed );
use Unicode::ICU::Collator qw( UCOL_NUMERIC_COLLATION UCOL_ON );

use MusicBrainz::Server::Validation qw( encode_entities );

with 'MusicBrainz::Server::Role::Translation' => { domain => 'mb_server' };

use Sub::Exporter -setup => {
    exports => [qw( l lp ln N_l N_ln N_lp get_collator comma_list comma_only_list expand )],
    groups => {
        default => [qw( l lp ln N_l N_ln N_lp comma_list comma_only_list expand )]
    }
};

has 'languages' => (
    isa => 'ArrayRef',
    is => 'rw',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_system_languages => 'elements',
    }
);

has 'bound' => (
    isa => 'Bool',
    is => 'rw',
    default => 0
);

# N_ functions are no-ops which return their arguments
# They only exist so the strings get into the catalogs
# There is one for each because the call signatures
# and what should appear in the catalogs differ.
#
# Normal translation, singular string.
# Takes one string argument and optionally a hashref of arguments to interpolate
sub l    { __PACKAGE__->instance->gettext(@_) }
sub N_l  { __PACKAGE__->instance->nop_gettext(@_) }
# Singular translation with context
# Takes one string to translate, a string of context, and an optional hashref
sub lp   { __PACKAGE__->instance->pgettext(@_) }
sub N_lp { __PACKAGE__->instance->nop_gettext(@_) }
# Plural translation (context can be within the string)
# Takes a singlular string, a plural string, and an optional hashref
sub ln   { __PACKAGE__->instance->ngettext(@_) }
sub N_ln { __PACKAGE__->instance->nop_ngettext(@_) }

sub _bind_domain
{
    my ($self, $domain) = @_;
    # copied from Locale::TextDomain lines 321-346, in sub __find_domain
    # I changed $try_dirs to @search_dirs, which I set myself based on line 303, in sub import
    # Otherwise the same. This is so we can use Locale::TextDomain's
    # search and textdomain binding code without using its crazy way
    # of determining which domain to use for a given string.
    my @search_dirs = map $_ . '/LocaleData', @INC;
    my $found_dir = '';

    TRYDIR: foreach my $dir (map { abs_path $_ } grep { -d $_ } @search_dirs) {
        local *DIR;
        if (opendir DIR, $dir) {
            my @files = map { "$dir/$_/LC_MESSAGES/$domain.mo" }
                grep { ! /^\.\.?$/ } readdir DIR;

            foreach my $file (@files) {
                if (-f $file || -l $file) {
                    # If we find a non-readable file on our way,
                    # we access has been disabled on purpose.
                    # Therefore no -r check here.
                    $found_dir = $dir;
                    last TRYDIR;
                }
            }
        }
    }

    bindtextdomain $domain => $found_dir;
    $self->{bound} = 1;
}

sub build_languages_from_header
{
    my ($self, $headers) = @_;
    $self->languages([
        I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs(
                $headers->header('Accept-Language')
            )
        ),
        'i-default'
    ]);
}

sub set_language
{
    my ($self, $lang) = @_;

    # Make sure everything is unset first.
    $ENV{LANGUAGE} = '';
    $ENV{LANG} = '';
    $ENV{OUTPUT_CHARSET} = '';
    $ENV{LC_ALL} = '';
    $ENV{LC_MESSAGES} = '';

    my @avail_lang;
    if (defined $lang) {
        @avail_lang = ($lang =~ s/-/_/gr);
    } elsif (DBDefs->LANGUAGE_FALLBACK_TO_BROWSER) {
        # change e.g. 'en-aq' to 'en_AQ'
        @avail_lang = map { s/-([a-z]{2})/_\U$1/; $_; }
            grep {
                my $l = $_;
                grep { $l eq $_ } DBDefs->MB_LANGUAGES
            } $self->all_system_languages;
    } else {
        @avail_lang = ('en');
    }
    my $set_lang = web_set_locale(\@avail_lang, [ 'utf-8' ], LC_MESSAGES);
    if (!defined $set_lang) {
        return 'en';
    }
    # Strip off charset
    $set_lang =~ s/\.utf-8//;
    my $set_lang_munge = $set_lang =~ s/_([A-Z]{2})/-\L$1/r;
    my $set_lang_nocountry = $set_lang =~ s/_[A-Z]{2}//r;
    # Change en_AQ back to en-aq to compare with MB_LANGUAGES
    if (any { $set_lang eq $_ || $set_lang_munge eq $_ } DBDefs->MB_LANGUAGES) {
        return $set_lang;
    }
    # Check if the language without country code is in MB_LANGUAGES
    elsif (any { $set_lang_nocountry eq $_ } DBDefs->MB_LANGUAGES) {
        return $set_lang_nocountry;
    }
    # Give up, return the full language even though it looks wrong
    else {
        return $set_lang;
    }
}

sub run_without_translations {
    my ($self, $code) = @_;

    my $prev_locale = setlocale(LC_MESSAGES);
    $self->unset_language();
    $code->();
    setlocale(LC_MESSAGES, $prev_locale);
    return;
}

sub unset_language
{
    web_set_locale([ 'en' ], [ 'utf-8' ], LC_MESSAGES);
}

sub language_from_cookie
{
    my ($self, $cookie) = @_;
    my $cookie_munge = defined $cookie ? $cookie->value : '';
    $cookie_munge =~ s/-([A-Z]{2})/-\L$1/;
    my $cookie_nocountry = defined $cookie ? $cookie->value : '';
    $cookie_nocountry =~ s/-[A-Z]{2}//;
    if (defined $cookie &&
        any { $cookie->value eq $_ || $cookie_munge eq $_ } DBDefs->MB_LANGUAGES) {
        return $cookie->value;
    } elsif (defined $cookie &&
             any { $cookie_nocountry eq $_ } DBDefs->MB_LANGUAGES) {
        return $cookie_nocountry;
    } else {
        return undef;
    }
}

sub all_languages
{
    my @lang_with_locale = sort_by { ucfirst $_->[1]->native_language }
                           map { [ $_ => DateTime::Locale->load($_) ] }
                           grep { my $l = $_;
                                  grep { $l eq $_ } DateTime::Locale->codes() }
                           map { s/-([a-z]{2})/-\U$1/r } DBDefs->MB_LANGUAGES;
    my @lang_without_locale = sort_by { $_->[1]->{id} }
                              map { [ $_ => {'id' => $_, 'native_language' => ''} ] }
                              grep { my $l = $_;
                                     !(grep { $l eq $_ } DateTime::Locale->codes()) }
                              map { s/-([a-z]{2})/-\U$1/r } DBDefs->MB_LANGUAGES;
    my @languages = (@lang_with_locale, @lang_without_locale);
    return \@languages;
}

sub expand {
    my ($self, $string, %args) = @_;

    my $make_link = sub {
        my ($var, $text) = @_;
        my $final_text = defined $args{$text} ? $args{$text} : $self->expand($text, %args);
        if (defined $args{$var}) {
            if (ref($args{$var}) eq 'HASH') {
                return '<a ' . join(' ', map { qq($_=") . encode_entities($args{$var}->{$_}) . q(") } sort keys %{ $args{$var} }) . '>' . $final_text . '</a>';
            } else {
                return '<a href="' . encode_entities($args{$var}) . '">' . $final_text . '</a>';
            }
        } else {
            return "{$var|$text}";
        }
    };

    my $result = '';
    my $remainder = $string;
    my $re = join '|', map { quotemeta $_ } keys %args;

    while (1) {
        my ($match, $prefix);
        ($match, $remainder, $prefix) = extract_bracketed($remainder, '{}', '[^{]*');

        $match //= '';
        $prefix //= '';
        return "${result}${prefix}${remainder}" unless $match;

        $match =~ s/^\{($re)\|(.*?)\}$/$make_link->($1, $2)/ge;
        $match =~ s/^\{($re)\}$/defined $args{$1} ? $args{$1} : "{$1}"/ge;
        $result .= "${prefix}${match}";
    }

    return $result;
}

sub get_collator
{
    my ($language) = @_;
    my $coll = Unicode::ICU::Collator->new($language);
    # make sure to update admin/sql/CreateCollations.sql as well
    $coll->setAttribute(UCOL_NUMERIC_COLLATION(), UCOL_ON());
    return $coll;
}

sub comma_list {
    return ($_[0] // '') if scalar(@_) <= 1;

    my ($last, $almost_last, @rest) = reverse(@_);

    my $output = l('{almost_last_list_item} and {last_list_item}', {
        last_list_item => $last,
        almost_last_list_item => $almost_last
    });

    for (@rest) {
        $output = l('{list_item}, {rest}', { list_item => $_, rest => $output });
    }

    return $output;
}

sub comma_only_list {
    return ($_[0] // '') if scalar(@_) <= 1;

    my ($last, @rest) = reverse(@_);

    my $output = l('{last_list_item}', { last_list_item => $last });

    for (@rest) {
        $output = l('{commas_only_list_item}, {rest}', { commas_only_list_item => $_, rest => $output });
    }

    return $output;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
