package MusicBrainz::Server::Form::CDStub;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_barcode );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'CDStub' );

has_field 'title' => (
    required => 1,
    type => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'barcode' => (
    type => '+MusicBrainz::Server::Form::Field::Barcode',
    maxlength => 255
);

has_field 'artist' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255
);

has_field 'tracks' => (
    type => 'Repeatable'
);

has_field 'multiple_artists' => (
    type => 'Checkbox'
);

has_field 'tracks.title' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
    maxlength => 255
);

has_field 'tracks.artist' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255
);

sub default_multiple_artists {
    my $self = shift;
    my $artist = $self->field('artist')->value;
    return !defined($artist) || $artist eq '';
}

sub validate_barcode {
    my ($self, $field) = @_;
    return unless $field->value;
    $field->add_error(l('Must be a valid barcode'))
        unless is_valid_barcode($field->value);
}

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
