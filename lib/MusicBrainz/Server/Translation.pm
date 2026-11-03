package MusicBrainz::Server::Translation;
use MooseX::Singleton;

use Cwd qw(abs_path);
use DBDefs;
use DateTime::Locale;
use I18N::LangTags ();
use I18N::LangTags::Detect;
use List::AllUtils qw( sort_by );
use Locale::Messages qw( bindtextdomain nl_putenv LC_MESSAGES );
use Locale::Util qw( web_set_locale );
use POSIX qw( setlocale );
use Text::Balanced qw( extract_bracketed );
use Unicode::ICU::Collator qw( UCOL_NUMERIC_COLLATION UCOL_ON );

use MusicBrainz::Server::Data::Utils qw( contains_string );
use MusicBrainz::Server::Validation qw( encode_entities );

with 'MusicBrainz::Server::Role::Translation' => { domain => 'mb_server' };

use Sub::Exporter -setup => {
    exports => [qw( l lp ln N_l N_ln N_lp get_collator comma_list comma_only_list expand )],
    groups => {
        default => [qw( l lp ln N_l N_ln N_lp comma_list comma_only_list expand )],
    },
};

has 'languages' => (
    isa => 'ArrayRef',
    is => 'rw',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_system_languages => 'elements',
    },
);

has 'bound' => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
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
    my @search_dirs = map { $_ . '/LocaleData' } @INC;
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

# Language codes in MB_LANGUAGES, in the lang cookie and in Accept-Language
# have the form ll[-Ssss][-CC] in any case, for example "fr-ca", "es-419" or
# "zh-hant". These functions give the POSIX form (fr_CA, zh_Hant) and the
# BCP 47 form (fr-CA, zh-Hant) of such a code. They only fix the case and the
# separators: a subtag of four characters becomes a script, and any other
# subtag a region. They do not check a code, and they do not support other
# BCP 47 subtags, for example variants or extensions.
sub _subtags
{
    my ($language, @subtags) = split /[-_]/, shift;
    return '' unless defined $language;
    return (lc $language,
            map { length $_ == 4 ? ucfirst lc $_ : uc $_ } @subtags);
}

sub posix_locale { join '_', _subtags(shift) }

sub bcp47_tag { join '-', _subtags(shift) }

sub _strip_last_subtag { shift =~ s/_[^_]+$//r }

sub _mb_languages { map { posix_locale($_) => 1 } DBDefs->MB_LANGUAGES }

# glibc has no locale with a script subtag, for example zh_Hant. For such a
# language, set_language selects this system locale, and LANGUAGE tells
# gettext to read the catalogs of the language. If the language has no
# catalogs of its own, gettext reads those of the language without its
# script: the Simplified Chinese catalogs are named zh, not zh_Hans. The
# browser build must also make a jed bundle for each key (SCRIPT_LOCALES in
# webpack/client.config.mjs).
my %SYSTEM_LOCALE_FOR = (
    zh_Hans => 'zh_CN',
    zh_Hant => 'zh_TW',
);

sub _set_gettext_language { nl_putenv('LANGUAGE=' . (shift // '')) }

sub build_languages_from_header
{
    my ($self, $headers) = @_;
    $self->languages([
        I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs(
                $headers->header('Accept-Language'),
            ),
        ),
        'i-default',
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
    _set_gettext_language();
    # glibc caches translations by locale name, and ignores a new LANGUAGE
    # value while the locale stays the same. For example, zh_TW and zh_Hant
    # both use the zh_TW locale. Start from the C locale, so that the locale
    # that set_language selects is always a change.
    setlocale(LC_MESSAGES, 'C');

    my %mb_languages = _mb_languages();
    my @avail_lang;
    if (defined $lang) {
        @avail_lang = (posix_locale($lang));
    } elsif (DBDefs->LANGUAGE_FALLBACK_TO_BROWSER) {
        @avail_lang = grep { $mb_languages{$_} }
                      map { posix_locale($_) } $self->all_system_languages;
    } else {
        @avail_lang = ('en');
    }

    my $set_lang;
    for my $avail_lang (@avail_lang) {
        my $system_locale = $SYSTEM_LOCALE_FOR{$avail_lang};
        if (defined $system_locale) {
            if (defined web_set_locale([ $system_locale ], [ 'utf-8' ], LC_MESSAGES)) {
                _set_gettext_language($avail_lang);
                return $avail_lang;
            }
            next;
        }
        $set_lang = web_set_locale([ $avail_lang ], [ 'utf-8' ], LC_MESSAGES);
        last if defined $set_lang;
    }
    if (!defined $set_lang) {
        # Force setting 'es_419' which seems to not be recognized by
        # Locale::Util most likely, or I18N::LangTags::Detect maybe.
        # A more definitive fix should be implemented for MBS-13446.
        return contains_string(\@avail_lang, 'es_419') ? 'es_419' : 'en';
    }
    # Strip off charset
    $set_lang =~ s/\.utf-8//;
    my $set_lang_parent = _strip_last_subtag($set_lang);
    if ($mb_languages{$set_lang}) {
        return $set_lang;
    }
    # Check if the language without its last subtag is in MB_LANGUAGES
    elsif ($mb_languages{$set_lang_parent}) {
        return $set_lang_parent;
    }
    # Give up, return the full language even though it looks wrong
    else {
        return $set_lang;
    }
}

sub run_without_translations {
    my ($self, $code) = @_;

    my $prev_locale = setlocale(LC_MESSAGES);
    my $prev_language = $ENV{LANGUAGE};
    $self->unset_language();
    $code->();
    setlocale(LC_MESSAGES, $prev_locale);
    _set_gettext_language($prev_language);
    return;
}

sub unset_language
{
    _set_gettext_language();
    web_set_locale([ 'en' ], [ 'utf-8' ], LC_MESSAGES);
}

sub language_from_cookie
{
    my ($self, $cookie) = @_;
    return undef unless defined $cookie && length $cookie->value;

    my %mb_languages = _mb_languages();
    my $cookie_lang = posix_locale($cookie->value);
    my $cookie_parent = _strip_last_subtag($cookie_lang);
    if ($mb_languages{$cookie_lang}) {
        return $cookie->value;
    } elsif ($mb_languages{$cookie_parent}) {
        return bcp47_tag($cookie_parent);
    } else {
        return undef;
    }
}

sub all_languages
{
    my %locale_codes = map { $_ => 1 } DateTime::Locale->codes();
    my @mb_languages = map { bcp47_tag($_) } DBDefs->MB_LANGUAGES;
    my @lang_with_locale = sort_by { ucfirst $_->[1]->native_language }
                           map { [ $_ => DateTime::Locale->load($_) ] }
                           grep { $locale_codes{$_} } @mb_languages;
    my @lang_without_locale = sort_by { $_->[1]->{id} }
                              map { [ $_ => {'id' => $_, 'native_language' => ''} ] }
                              grep { !$locale_codes{$_} } @mb_languages;
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
        almost_last_list_item => $almost_last,
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
