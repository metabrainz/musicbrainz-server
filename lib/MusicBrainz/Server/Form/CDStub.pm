package MusicBrainz::Server::Form::CDStub;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( N_l l );
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

has_field 'multiple_artists' => (
    type => 'Checkbox'
);

has_field 'tracks' => (
    type => 'Repeatable',
    required => 1,
    required_message => N_l('You must provide at least one track'),
    localize_meth => sub { my ($self, @message) = @_; return l(@message); },
    init_contains => {
        required_message => N_l('You must provide a title for track {0}'),
        localize_meth => sub {
            my ($self, $message, @params) = @_;
            my $count = 0;
            my %params = map { $count++ => $_ } @params;
            # hack
            $params{0}++ if ($message == 'You must provide a title for track {0}');
            return l($message, \%params);
        }
    }
);

has_field 'tracks.title' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1, # messages, stupidly, must be in field 'tracks' above
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
