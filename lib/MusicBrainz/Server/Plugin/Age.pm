package MusicBrainz::Server::Plugin::Age;

use strict;
use warnings;

use base 'Template::Plugin';

use Time::Duration;

sub new {
    my ($class, $context) = @_;
    return bless {
        c => $context
    }, $class;
}

# format called using
# Age.format(timestamp, '{age} ago')
sub format {
    my ($self, $dt, $format) = @_;
    return unless $dt;

    my $stash = $self->{c}->localise;
    my $ret = $stash->{c}->gettext($format, { 
        age => Time::Duration::duration(DateTime->now->epoch - $dt->epoch, 1) 
    });
    $self->{c}->delocalise;

    return $ret;
}

1;
