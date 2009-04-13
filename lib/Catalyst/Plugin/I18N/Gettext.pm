package Catalyst::Plugin::I18N::Gettext;

use strict;
use warnings;

use DBDefs;

use I18N::LangTags ();
use I18N::LangTags::Detect;

use Data::Dumper;

use Locale::TextDomain q/mb_server/;

our $VERSION = '0.01';

sub setup {
    my $self = shift;
    $self->NEXT::setup(@_);
}

sub _set_language {

    my $c = shift;

    $c->{languages} ||= [
        I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs(
                $c->request->header('Accept-Language')
            )
          ),
        'i-default'
    ];

    my @avail_lang = grep { my $l = $_ ; grep {$l eq $_ } DBDefs::MB_LANGUAGES } @{$c->{languages}};

    $ENV{LANGUAGE} = $avail_lang[0];
}

sub gettext
{
	my ($c, $msgid, $vars) = @_;


        my %vars = %$vars if (ref $vars eq "HASH");

        _set_language($c);

	return __expand(__($msgid), %vars);
}

sub ngettext
{
	my ($c, $msgid, $msgid_plural, $n, $vars) = @_;

        my %vars = %$vars if (ref $vars eq "HASH");

        _set_language($c);


	return __expand(__n($msgid, $msgid_plural, $n), %vars);
}


sub __expand
{
    my ($translation, %args) = @_;

    my $re = join '|', map { quotemeta $_ } keys %args;

    $translation =~ s/\{($re)\|(.*?)\}/defined $args{$1} ? "<a href=\"" . $args{$1} . "\">$2<\/a>" : "{$1}"/ge;
    $translation =~ s/\{($re)\}/defined $args{$1} ? $args{$1} : "{$1}"/ge;

    return $translation;
}


1;
