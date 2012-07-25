package MusicBrainz::Server::Plugin::Translation;

use strict;
use warnings;

use base 'Template::Plugin';
use MusicBrainz::Server::Translation ();
use MusicBrainz::Server::Translation::Statistics ();

sub domain { shift->{domain}; }

sub new {
    my ($class, $context, $domain) = @_;

    # support only mb_server and statistics, for now
    $domain = 'mb_server' unless $domain && $domain eq 'statistics';

    return bless {
        domain => $domain,
    }, $class;
}

sub l {
    my ($self, $msgid, $vars) = @_;

    if ($self->domain eq 'statistics') {
    return MusicBrainz::Server::Translation::Statistics::l($msgid, $vars);
    } else {
    return MusicBrainz::Server::Translation::l($msgid, $vars);
    }
}

sub ln {
    my ($self, $msgid, $msgid_plural, $num, $vars) = @_;

    if ($self->domain eq 'statistics') {
    return MusicBrainz::Server::Translation::Statistics::ln($msgid, $msgid_plural, $num, $vars);
    } else {
    return MusicBrainz::Server::Translation::ln($msgid, $msgid_plural, $num, $vars);
    }
}

sub lp {
    my ($self, $msgid, $msgctxt, $vars) = @_;

    if ($self->domain eq 'statistics') {
    return MusicBrainz::Server::Translation::Statistics::lp($msgid, $msgctxt, $vars);
    } else {
    return MusicBrainz::Server::Translation::lp($msgid, $msgctxt, $vars);
    }
}

1;
