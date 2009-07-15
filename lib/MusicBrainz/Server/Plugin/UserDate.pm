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
    my ($self, $date) = @_;
    return unless $date;

    my %opts;
    if ($self->preferences) {
        $opts{tz            } = $self->preferences->timezone;
        $opts{datetimeformat} = $self->preferences->datetime_format;
    }

    return MusicBrainz::Server::DateTime::format_datetime(\%opts, $date);
}

1;
