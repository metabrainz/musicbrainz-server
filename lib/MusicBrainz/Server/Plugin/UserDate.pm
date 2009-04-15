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
        $opts{tz            } = $self->preferences->get('timezone');
        $opts{datetimeformat} = $self->preferences->get('datetimeformat');
    }

    return MusicBrainz::Server::DateTime::format_datetime(\%opts, $date);
}

1;
