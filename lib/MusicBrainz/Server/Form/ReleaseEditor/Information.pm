package MusicBrainz::Server::Form::ReleaseEditor::Information;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

# Release information
has_field 'name'             => ( type => 'Text'      );
has_field 'various_artists'  => ( type => 'Checkbox'  );

has_field 'artist_credit'    => ( type => '+MusicBrainz::Server::Form::Field::ArtistCredit' );
has_field 'type_id'          => ( type => 'Select'    );
has_field 'status_id'        => ( type => 'Select'    );
has_field 'language_id'      => ( type => 'Select'    );
has_field 'script_id'        => ( type => 'Select'    );

# Release event
has_field 'date'             => ( type => '+MusicBrainz::Server::Form::Field::PartialDate' );
has_field 'country_id'       => ( type => 'Select'    );
has_field 'packaging_id'     => ( type => 'Select'    );

has_field 'labels'           => ( type => 'Repeatable' );
has_field 'labels.catalog_number' => ( type => 'Text' );
has_field 'labels.deleted'   => ( type => 'Checkbox' );
has_field 'labels.label_id'  => ( type => 'Text' );
has_field 'labels.name'      => ( type => 'Text' );

has_field 'barcode'           => ( type => '+MusicBrainz::Server::Form::Field::Barcode' );

# Additional information
has_field 'annotation'       => ( type => 'TextArea'  );

sub options_type_id           { shift->_select_all('ReleaseGroupType') }
sub options_status_id         { shift->_select_all('ReleaseStatus') }
sub options_packaging_id      { shift->_select_all('ReleasePackaging') }
sub options_country_id        { shift->_select_all('Country') }
sub options_language_id       { shift->_select_all('Language') }
sub options_script_id         { shift->_select_all('Script') }


after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object)
    {
        $self->field ('type_id')->value ($self->init_object->release_group->type->id)
            if $self->init_object->release_group->type;
        $self->field ('type_id')->disabled (1);

        my $max = @{ $self->init_object->labels } - 1;
        for (0..$max)
        {
            my $name = $self->init_object->labels->[$_]->label->name;
            $self->field ('labels')->fields->[$_]->field ('name')->value ($name);
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
