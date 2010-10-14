package MusicBrainz::Server::Form::CDStub;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'CDStub' );

has_field 'title' => (
    required => 1,
    type => 'Text',
);

has_field 'comment' => (
    type => 'Text',
);

has_field 'barcode' => (
    type => '+MusicBrainz::Server::Form::Field::Barcode'
);

has_field 'artist' => (
    type => 'Text',
);

has_field 'tracks' => (
    type => 'Repeatable'
);

has_field 'single_artist' => (
    type => 'Checkbox'
);

has_field 'tracks.title' => (
    type => 'Text',
    required => 1
);

has_field 'tracks.artist' => (
    type => 'Text',
);

sub default_single_artist { shift->field('artist')->value ne '' }

sub validate
{
    my $self = shift;
    if ($self->field('single_artist')->value) {
        $self->field('artist')->required(1);
        $self->field('artist')->validate_field;

        for my $field ($self->field('tracks')->fields) {
            $field = $field->field('artist');
            $field->add_error('You may not specify a combination of track artists and a release artist')
                if $field->value;
        }
    }
    else {
        $self->field('artist')->add_error('You may not specify a release artist while also specifying track artists')
            if $self->field('artist')->value;

        for my $field ($self->field('tracks')->fields) {
            $field = $field->field('artist');
            $field->required(1);
            $field->validate_field;
        }
    }
}

1;
