package MusicBrainz::Server::Translation;
use MooseX::Singleton;

use Encode;
use I18N::LangTags ();
use I18N::LangTags::Detect;
use Locale::TextDomain q/mb_server/;
use DBDefs;

use Sub::Exporter -setup => {
    exports => [qw( l ln )],
    groups => {
        default => [qw( l ln )]
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
    return if $ENV{LANGUAGE};

    my @avail_lang = grep {
        my $l = $_;
        grep { $l eq $_ } DBDefs::MB_LANGUAGES
    } $self->all_system_languages;

    $ENV{LANGUAGE} = $avail_lang[0] if @avail_lang;
}

sub gettext
{
    my ($self, $msgid, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_set_language;

    return _expand(__($msgid), %vars) if $msgid;
}

sub ngettext {
    my ($self, $msgid, $msgid_plural, $n, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_set_language;

    return _expand(__n($msgid, $msgid_plural, $n), %vars);
}

sub _expand
{
    my ($string, %args) = @_;

    $string = decode('utf-8', $string);

    my $re = join '|', map { quotemeta $_ } keys %args;

    $string =~ s/\{($re)\|(.*?)\}/defined $args{$1} ? "<a href=\"" . $args{$1} . "\">" . (defined $args{$2} ? $args{$2} : $2) . "<\/a>" : "{$0}"/ge;
    $string =~ s/\{($re)\}/defined $args{$1} ? $args{$1} : "{$1}"/ge;

    return $string;
}

sub l  { __PACKAGE__->instance->gettext(@_) }
sub ln { __PACKAGE__->instance->ngettext(@_) }

1;
