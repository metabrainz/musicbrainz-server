package MusicBrainz::Server::Form::Artist;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Edit';

has '+name' => ( default => 'edit-artist' );

has_field 'name' => (
    type => 'Text',
    required => 1,
);

has_field 'sort_name' => (
    type => 'Text',
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

has_field 'begin_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
);

has_field 'end_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
);

has_field 'comment' => (
    type => 'Text',
);

has_field 'not_dupe' => (
    type => 'Boolean',
);

sub edit_field_names
{
    return qw( name sort_name type_id gender_id country_id
               begin_date end_date comment );
}

sub options_gender_id   { shift->_select_all('Gender') }
sub options_type_id     { shift->_select_all('ArtistType') }
sub options_country_id  { shift->_select_all('Country') }

has 'duplicates' => (
    traits => [ 'Array' ],
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    handles => {
        has_duplicates => 'count'
    }
);

sub validate
{
    my $self = shift;

    # Don't check for dupes if the not_dupe checkbox is ticked, or the
    # user hasn't changed the artist's name
    return if $self->field('not_dupe')->value;
    return if $self->init_object && $self->init_object->name eq $self->field('name')->value;

    $self->duplicates([ $self->ctx->model('Artist')->find_by_name($self->field('name')->value) ]);

    $self->field('not_dupe')->required($self->has_duplicates ? 1 : 0);
    $self->field('not_dupe')->validate_field;
}

1;
