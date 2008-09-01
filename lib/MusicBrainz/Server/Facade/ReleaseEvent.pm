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
        catalog_number => $event->GetCatNo,
        country        => $event->country,
        date           => $event->GetSortDate,
        format         => $event->GetFormat ? $event->GetFormatName : "",
        barcode        => $event->GetBarcode,
        label          => MusicBrainz::Server::Facade::Label->new({
            name => $event->GetLabelName,
            mbid => $event->GetLabelMBId,
        }),
    });
}

1;
