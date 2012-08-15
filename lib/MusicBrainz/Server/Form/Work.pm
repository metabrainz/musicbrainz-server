package MusicBrainz::Server::Form::Work;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( language_options );
use List::AllUtils qw( uniq );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-work' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'language_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type      => '+MusicBrainz::Server::Form::Field::Comment',
    maxlength => 255
);

has_field 'iswcs' => (
    type => 'Repeatable',
    deflation => sub {
        my ($value) = @_;
        return [ map { $_->iswc } @$value ];
    }
);

has_field 'iswcs.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISWC',
);

after 'validate' => sub {
    my ($self) = @_;
    return if $self->has_errors;

    my $iswcs =  $self->field('iswcs');
    $iswcs->value([ uniq sort grep { $_ } @{ $iswcs->value } ]);
};

sub edit_field_names { qw( type_id language_id name comment artist_credit ) }

sub options_type_id           { shift->_select_all('WorkType') }
sub options_language_id       { return language_options (shift->ctx); }

1;
