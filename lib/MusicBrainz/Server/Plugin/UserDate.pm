package MusicBrainz::Server::Plugin::UserDate;

use strict;
use warnings;

use base 'Template::Plugin';

sub preferences { shift->{preferences}; }
sub locale { shift->{locale}; }

sub new {
    my ($class, $context, $preferences, $locale) = @_;
    return bless {
        preferences => $preferences,
        locale => $locale,
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

    if ($self->locale) {
        $dt->set_locale($self->locale);
    }

    return $dt->strftime($format);
}

1;
