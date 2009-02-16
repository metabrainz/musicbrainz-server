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
                type  => 'Text',
                order => 5,
            },
            format  => {
                type  => 'Select',
                order => 6
            },
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

1;
