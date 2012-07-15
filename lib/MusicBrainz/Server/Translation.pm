package MusicBrainz::Server::Translation;
use MooseX::Singleton;

use Encode;
use I18N::LangTags ();
use I18N::LangTags::Detect;
use DBDefs;

use Locale::Messages qw( bindtextdomain LC_MESSAGES );
use Locale::Util qw( web_set_locale );
use Cwd qw (abs_path);

with 'MusicBrainz::Server::Role::Translation' => { domain => 'mb_server' };

use Sub::Exporter -setup => {
    exports => [qw( l lp ln N_l )],
    groups => {
        default => [qw( l lp ln N_l )]
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

sub N_l { __PACKAGE__->instance->nop_gettext(@_) }
sub l { __PACKAGE__->instance->gettext(@_) }
sub lp { __PACKAGE__->instance->pgettext(@_) }
sub ln { __PACKAGE__->instance->ngettext(@_) }

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

sub _set_language
{
    my $self = shift;

    # Make sure everything is unset first.
    $ENV{LANGUAGE} = '';
    $ENV{LANG} = '';
    $ENV{OUTPUT_CHARSET} = '';
    $ENV{LC_ALL} = '';
    $ENV{LC_MESSAGES} = '';

    my @avail_lang = grep {
        my $l = $_;
        grep { $l eq $_ } DBDefs::MB_LANGUAGES
    } $self->all_system_languages;

    # change e.g. 'en-aq' to 'en_AQ'
    @avail_lang = map { s/-([a-z]{2})/_\U$1/; $_; } @avail_lang;
    web_set_locale(\@avail_lang, [ 'utf-8' ], LC_MESSAGES);
}

sub _unset_language
{
    web_set_locale([ 'en' ], [ 'utf-8' ], LC_MESSAGES);
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
