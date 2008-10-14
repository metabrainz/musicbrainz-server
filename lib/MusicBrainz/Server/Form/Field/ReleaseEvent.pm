package MusicBrainz::Server::Form::Field::ReleaseEvent;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Field::Compound';

sub profile
{
    return {
        required => {
            date    => {
                type  => '+MusicBrainz::Server::Form::Field::Date',
                order => 1,
            },
            country => {
                type => 'Select',
                order => 2
            },
            label => {
                type  => 'Text',
                order => 3,
            },
            catalog_number => {
                type  => 'Text',
                order => 4,
                size  => 10,
            },
            barcode => {
                type  => 'Text',
                order => 4,
                size  => 13,
            },
            format => {
                type  => '+MusicBrainz::Server::Form::Field::ReleaseFormat',
                order => 5,
            },
        }
    }
}

sub init
{
    my $self = shift;

    $self->SUPER::init(@_);

    $self->sub_form->load_options;
}

sub options_country
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Country->new($mb->{DBH});

    return map { $_->id => $_->name } $c->All;
}

sub field_value
{
    my ($self, $field_name, $event) = @_;

    use Switch;
    switch ($field_name)
    {
        case ('date')    { return $event->sort_date; }
        case ('label')   { return $event->label->name; }
        case ('country') { return $event->country; }
        case ('barcode') { return $event->barcode; }
    }
}

1;
