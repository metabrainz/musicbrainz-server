package MusicBrainz::Server::Form::Recording;
use utf8;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use List::AllUtils qw( uniq );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

# MBS-11428: When making changes to this module, please make sure to
# keep MusicBrainz::Server::Controller::WS::js::Edit in sync with it

has '+name' => ( default => 'edit-recording' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'length' => (
    type => '+MusicBrainz::Server::Form::Field::Length'
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit'
);

has_field 'isrcs' => (
    type => 'Repeatable',
    inflate_default_method => \&inflate_isrcs
);

has_field 'isrcs.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISRC',
);

has_field 'video' => (
    type => 'Checkbox'
);

has 'used_by_tracks' => (
    is => 'ro',
    isa => 'Bool',
    required => 1
);

after 'validate' => sub {
    my ($self) = @_;
    return if $self->has_errors;

    my $isrcs =  $self->field('isrcs');
    $isrcs->value([ uniq sort grep { $_ } @{ $isrcs->value } ]);

    my $length = $self->field('length');

    if ($self->used_by_tracks && defined($length->value) &&
        $length->value != $length->init_value) {
        $length->add_error(l(
            'This recording’s duration is determined by the tracks that are ' .
            'linked to it, and cannot be changed directly.'
        ));
    }
};

sub inflate_isrcs {
    my ($self, $value) = @_;
    return [ map { $_->isrc } @$value ];
}

sub edit_field_names
{
    return qw( name length comment artist_credit video );
}

1;
