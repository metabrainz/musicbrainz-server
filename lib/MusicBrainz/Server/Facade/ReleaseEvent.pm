package MusicBrainz::Server::Facade::ReleaseEvent;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    country
    catalog_number
    date
    format
    barcode
    label
});

sub new_from_event
{
    my ($class, $event) = @_;

    return $class->new({
        catalog_number => $event->cat_no,
        country        => $event->country,
        date           => $event->sort_date,
        format         => $event->format ? $event->format_name : "",
        barcode        => $event->barcode,
        label          => MusicBrainz::Server::Facade::Label->new({
            name => $event->label_name,
            mbid => $event->label_mbid,
        }),
    });
}

1;
