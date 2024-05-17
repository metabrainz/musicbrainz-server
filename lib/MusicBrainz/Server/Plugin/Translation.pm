package MusicBrainz::Server::Plugin::Translation;

use strict;
use warnings;

use base 'Template::Plugin';
use Encode qw( encode );
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

    $msgid = encode('utf-8', $msgid);

    if ($self->domain eq 'statistics') {
        return MusicBrainz::Server::Translation::Statistics::l($msgid, $vars);
    } else {
        return MusicBrainz::Server::Translation::l($msgid, $vars);
    }
}

sub ln {
    my ($self, $msgid, $msgid_plural, $num, $vars) = @_;

    $msgid = encode('utf-8', $msgid);

    if ($self->domain eq 'statistics') {
        return MusicBrainz::Server::Translation::Statistics::ln($msgid, $msgid_plural, $num, $vars);
    } else {
        return MusicBrainz::Server::Translation::ln($msgid, $msgid_plural, $num, $vars);
    }
}

sub N_ln { shift; return @_; }

sub lp {
    my ($self, $msgid, $msgctxt, $vars) = @_;

    $msgid = encode('utf-8', $msgid);

    if ($self->domain eq 'statistics') {
        return MusicBrainz::Server::Translation::Statistics::lp($msgid, $msgctxt, $vars);
    } else {
        return MusicBrainz::Server::Translation::lp($msgid, $msgctxt, $vars);
    }
}

sub expand {
    my ($self, $string, $args) = @_;

    return MusicBrainz::Server::Translation->instance->expand($string, %$args);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
