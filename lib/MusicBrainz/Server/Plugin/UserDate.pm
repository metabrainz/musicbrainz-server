package MusicBrainz::Server::Plugin::UserDate;

use strict;
use warnings;
use DateTime;

use base 'Template::Plugin';

sub preferences { shift->{preferences}; }

sub new {
    my ($class, $context, $preferences) = @_;
    return bless {
        preferences => $preferences,
    }, $class;
}

sub format {
    my ($self, $dt) = @_;

    return unless $dt;

    my $format;
    if ($self->preferences) {
        $dt = $dt->clone();
        $dt->set_time_zone($self->preferences->timezone);
        $format = $self->preferences->datetime_format;
    }
    else {
        $format = '%F %H:%M:%S %Z';
    }

    return $dt->strftime($format);
}

sub countdown
{
    my ($self, $future) = @_;

    my $now = DateTime->now;
    return 'N/A' unless $future > $now;

    my $diff = $future->subtract_datetime($now);
    my $delta = $now->delta_days($future)->delta_days;

    my $dfn = $self->format($future);

    if ($delta > 0) {
        return 'Expires in <dfn title="' . $dfn . '">' . $delta . '</dfn> days.';
    } else {
        return 'Expires in ' . $diff->hours . ' hours, and ' . $diff->minutes . ' minutes.';
    }
}

1;
