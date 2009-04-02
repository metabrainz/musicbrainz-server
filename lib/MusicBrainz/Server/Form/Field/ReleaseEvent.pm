package MusicBrainz::Server::Form::Field::ReleaseEvent;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Field::Compound';

use MusicBrainz::Server::ReleaseEvent;

sub profile
{
    return {
        required => {
            date    => {
                type  => '+MusicBrainz::Server::Form::Field::Date',
                order => 1,
            }
        },
        optional => {
            country => {
                type  => 'Select',
                order => 2,
            },
            label   => {
                type  => 'Text',
                order => 3,
            },
            catalog => {
                type  => 'Text',
                order => 4,
            },
            barcode => {
                type  => '+MusicBrainz::Server::Form::Field::Barcode',
                order => 5,
            },
            format  => {
                type  => 'Select',
                order => 6
            },
            remove => 'Checkbox',
        }
    }
}

sub options_country
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Country->new($mb->{dbh});

    return map { $_->id => $_->name } $c->All;
}

sub options_format
{
    MusicBrainz::Server::ReleaseEvent::release_formats;
}

sub field_value
{
    my ($self, $field_name, $event) = @_;

    use Switch;
    switch ($field_name)
    {
        case (/date/) { return $event->sort_date; }
        case ('format') { return $event->format; }
        case ('barcode') { return $event->barcode; }
        case ('label') { return $event->label->name || ''; }
        case ('country') { return $event->country; }
        case ('catalog') { return $event->cat_no; }
    }
}

1;
