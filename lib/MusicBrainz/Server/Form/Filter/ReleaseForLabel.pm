package MusicBrainz::Server::Form::Filter::ReleaseForLabel;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Filter::Release';

sub options_label_id {
    my ($self, $field) = @_;
    return [
        map +{ value => $_->id, label => $_->name },
        @{ $self->labels },
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_label_id} = $self->options_label_id;
    return $json;
};

1;
