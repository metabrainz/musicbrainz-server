package MusicBrainz::Server::Form::ReleaseGroup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-release-group' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type      => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
    required => 1
);

has_field 'secondary_type_ids' => (
    type => 'Select',
    multiple => 1
);

sub options_type_id { shift->_select_all('ReleaseGroupType') }
sub options_secondary_type_ids { shift->_select_all('ReleaseGroupSecondaryType') }

sub edit_field_names { qw( type_id name comment artist_credit ) }

after BUILD => sub {
    my $self = shift;

    if (defined $self->init_object) {
        $self->field('secondary_type_ids')->value(
            [ map { $_->id } $self->init_object->all_secondary_types ]
        );
    }
};

1;
