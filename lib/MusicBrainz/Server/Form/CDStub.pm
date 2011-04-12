package MusicBrainz::Server::Form::CDStub;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'CDStub' );

has_field 'title' => (
    required => 1,
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'barcode' => (
    type => '+MusicBrainz::Server::Form::Field::Barcode'
);

has_field 'artist' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'tracks' => (
    type => 'Repeatable'
);

has_field 'multiple_artists' => (
    type => 'Checkbox'
);

has_field 'tracks.title' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'tracks.artist' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

sub default_multiple_artists { shift->field('artist')->value eq '' }

sub validate
{
    my $self = shift;
    if ($self->field('multiple_artists')->value) {
        $self->field('artist')->add_error('You may not specify a release artist while also specifying track artists')
            if $self->field('artist')->value;

        for my $field ($self->field('tracks')->fields) {
            $field = $field->field('artist');
            $field->required(1);
            $field->validate_field;
        }
    }
    else {
        $self->field('artist')->required(1);
        $self->field('artist')->validate_field;

        for my $field ($self->field('tracks')->fields) {
            $field = $field->field('artist');
            $field->add_error('You may not specify a combination of track artists and a release artist')
                if $field->value;
        }
    }
}

1;
