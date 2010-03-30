package MusicBrainz::Server::Plugin::Countdown;

use strict;
use warnings;

use base 'Template::Plugin';

use DateTime;

sub preferences { shift->{preferences}; }

sub new {
    my ($class, $context) = @_;
    return bless {
        c => $context
    }, $class;
}

sub format {
    my ($self, $dt, $format) = @_;
    return unless $dt;

    my $dur = $dt - DateTime->now;

    my $stash = $self->{c}->localise;
    my $ret = $stash->{c}->gettext($format, {
        map { $_ => $dur->$_ } qw( days hours minutes )
    });
    $self->{c}->delocalise;

    return $ret;
}

1;
