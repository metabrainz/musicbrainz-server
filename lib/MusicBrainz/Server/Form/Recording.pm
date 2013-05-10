package MusicBrainz::Server::Form::Recording;
use HTML::FormHandler::Moose;
use List::AllUtils qw( uniq );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

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
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
    required => 1
);

has_field 'isrcs' => (
    type => 'Repeatable',
    inflate_default_method => \&inflate_isrcs
);

has_field 'isrcs.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISRC',
);

after 'validate' => sub {
    my ($self) = @_;
    return if $self->has_errors;

    my $isrcs =  $self->field('isrcs');
    $isrcs->value([ uniq sort grep { $_ } @{ $isrcs->value } ]);
};

sub inflate_isrcs {
    my ($self, $value) = @_;
    return [ map { $_->isrc } @$value ];
}

sub edit_field_names
{
    return qw( name length comment artist_credit );
}

sub options_type_id { shift->_select_all('RecordingType') }

1;
