package MusicBrainz::Server::Plugin::UserDate;

use strict;
use warnings;

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
        $format = '%Y-%m-%d %H:%M %Z';
    }

    return $dt->strftime($format);
}

1;
