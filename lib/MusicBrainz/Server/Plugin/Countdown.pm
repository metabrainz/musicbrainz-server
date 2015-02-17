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

# format called using
# Countdown.format(edit.expires_time, 'Expires in {week} week {hours} hours {minutes} minutes')
sub format {
    my ($self, $dt, $format) = @_;
    return unless $dt;

    my $dur = $dt - DateTime->now;

    my $stash = $self->{c}->localise;
    my $ret = $stash->{c}->gettext($format, {
        map { $_ => $dur->$_ } qw( weeks days hours minutes )
    });
    $self->{c}->delocalise;

    return $ret;
}

sub in_the_future {
    my ($self, $dt) = @_;
    return unless $dt && $dt > DateTime->now;
}

sub weeks {
    my ($self, $dt) = @_;

    my $dur = $dt - DateTime->now;

    return $dur->weeks;
}

sub days {
    my ($self, $dt) = @_;

    my $dur = $dt - DateTime->now;

    # $dur->days is defined strangely, as:
    # abs( ( $dur->in_units( 'days', 'weeks' ) )[0] )
    # weeks and hours are defined following this pattern instead:
    return abs( $dur->in_units( 'days' ) )
}

sub hours {
    my ($self, $dt) = @_;

    my $dur = $dt - DateTime->now;

    return $dur->hours;
}

sub minutes {
    my ($self, $dt) = @_;

    my $dur = $dt - DateTime->now;

    # $dur->minutes is defined strangely, as:
    # abs( ( $dur->in_units( 'minutes', 'hours' ) )[0] )
    # weeks and hours are defined following this pattern instead:
    return abs( $dur->in_units( 'minutes' ) );
}

1;
