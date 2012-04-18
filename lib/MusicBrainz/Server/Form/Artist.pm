package MusicBrainz::Server::Form::Artist;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::DatePeriod';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';

has '+name' => ( default => 'edit-artist' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'sort_name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'gender_id' => (
    type => 'Select',
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'country_id' => (
    type => 'Select',
);

has_field 'comment' => (
    type      => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255
);

has_field 'ipi_codes'          => ( type => 'Repeatable', num_when_empty => 1 );
has_field 'ipi_codes.code'     => ( type => '+MusicBrainz::Server::Form::Field::IPI' );
has_field 'ipi_codes.deleted'  => ( type => 'Checkbox' );

sub edit_field_names
{
    return qw( name sort_name type_id gender_id country_id
               begin_date end_date comment ipi_code );
}

sub options_gender_id   { shift->_select_all('Gender') }
sub options_type_id     { shift->_select_all('ArtistType') }
sub options_country_id  { shift->_select_all('Country') }

sub dupe_model { shift->ctx->model('Artist') }

sub validate {
    my ($self) = @_;

    if ($self->field('type_id')->value &&
        $self->field('type_id')->value == 2) {
        if ($self->field('gender_id')->value) {
            $self->field('gender_id')->add_error('Group artists cannot have a gender');
        }
    }
}

after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object)
    {
        my $max = @{ $self->init_object->ipi_codes } - 1;
        for (0..$max)
        {
            $self->field ('ipi_codes')->fields->[$_]->field ('code')->value (
                $self->init_object->ipi_codes->[$_]->ipi);
        }

    }
};

1;
