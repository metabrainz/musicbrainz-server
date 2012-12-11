package MusicBrainz::Server::Translation;
use MooseX::Singleton;

use Encode;
use I18N::LangTags ();
use I18N::LangTags::Detect;
use DBDefs;

use Locale::Messages qw( bindtextdomain LC_MESSAGES );
use Locale::Util qw( web_set_locale );
use Cwd qw (abs_path);
use DateTime::Locale;
use List::UtilsBy qw( sort_by );

with 'MusicBrainz::Server::Role::Translation' => { domain => 'mb_server' };

use Sub::Exporter -setup => {
    exports => [qw( l lp ln N_l N_ln N_lp )],
    groups => {
        default => [qw( l lp ln N_l N_ln N_lp )]
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
        @avail_lang = ($lang);
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
    # because s///r is a perl 5.14 feature
    my $set_lang_munge = $set_lang;
    $set_lang_munge =~ s/_([A-Z]{2})/-\L$1/;
    my $set_lang_nocountry = $set_lang;
    $set_lang_nocountry =~ s/_[A-Z]{2}//;
    # Change en_AQ back to en-aq to compare with MB_LANGUAGES
    if (grep { $set_lang eq $_ || $set_lang_munge eq $_ } DBDefs->MB_LANGUAGES) {
        return $set_lang;
    } 
    # Check if the language without country code is in MB_LANGUAGES
    elsif (grep { $set_lang_nocountry eq $_ } DBDefs->MB_LANGUAGES) {
        return $set_lang_nocountry;
    } 
    # Give up, return the full language even though it looks wrong
    else {
        return $set_lang;
    } 
}

sub unset_language
{
    web_set_locale([ 'en' ], [ 'utf-8' ], LC_MESSAGES);
}

sub language_from_cookie
{
    my ($self, $cookie) = @_;
    my $cookie_munge = defined $cookie ? $cookie->value : '';
    $cookie_munge =~ s/_([A-Z]{2})/-\L$1/;
    my $cookie_nocountry = defined $cookie ? $cookie->value : '';
    $cookie_nocountry =~ s/_[A-Z]{2}//;
    if (defined $cookie && 
        grep { $cookie->value eq $_ || $cookie_munge eq $_ } DBDefs->MB_LANGUAGES) {
        return $cookie->value;
    } elsif (defined $cookie && 
             grep { $cookie_nocountry eq $_ } DBDefs->MB_LANGUAGES) {
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
                                  grep { $l eq $_ } DateTime::Locale->ids() } 
                           map { s/-([a-z]{2})/_\U$1/; $_; } DBDefs->MB_LANGUAGES;
    my @lang_without_locale = sort_by { $_->[1]->{id} } 
                              map { [ $_ => {'id' => $_, 'native_language' => ''} ] } 
                              grep { my $l = $_; 
                                     !(grep { $l eq $_ } DateTime::Locale->ids()) } 
                              map { s/-([a-z]{2})/_\U$1/; $_; } DBDefs->MB_LANGUAGES;
    my @languages = (@lang_with_locale, @lang_without_locale);
    return \@languages;
}

sub _expand
{
    my ($self, $string, %args) = @_;

    $string = decode('utf-8', $string);

    my $re = join '|', map { quotemeta $_ } keys %args;

    $string =~ s/\{($re)\|(.*?)\}/defined $args{$1} ? "<a href=\"" . $args{$1} . "\">" . (defined $args{$2} ? $args{$2} : $2) . "<\/a>" : "{$0}"/ge;
    $string =~ s/\{($re)\}/defined $args{$1} ? $args{$1} : "{$1}"/ge;

    return $string;
}

1;
