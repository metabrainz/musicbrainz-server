package MusicBrainz::Server::Plugin::UserDate;

use strict;
use warnings;
use DateTime::Format::Pg;
use Text::Trim qw( trim );

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
    my ($self, $dt, $opts) = @_;

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

    if ($opts && $opts->{date_only}) {
        $format =~ s/%c/%x/;
        $format =~ s/%H:%M(:%S)?//;
        $format =~ s/%Z//;
        $format =~ s/,\s*$//;
        $format = trim($format);
    }

    return $dt->strftime($format);
}

sub format_pg_string {
    my ($self, $str, $opts) = @_;

    return unless $str;

    my $dt = DateTime::Format::Pg->parse_datetime($str);
    return $self->format($dt, $opts);
}

1;
