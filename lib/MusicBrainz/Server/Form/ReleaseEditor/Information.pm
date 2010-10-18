package MusicBrainz::Server::Form::ReleaseEditor::Information;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

# Release information
has_field 'name'             => ( type => 'Text'      );
has_field 'various_artists'  => ( type => 'Checkbox'  );
has_field 'release_group_id' => ( type => 'Hidden'    );

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

has_field 'barcode'          => ( type => '+MusicBrainz::Server::Form::Field::Barcode' );

# Additional information
has_field 'annotation'       => ( type => 'TextArea'  );
has_field 'comment'          => ( type => 'Text', maxlength => 255 );


sub options_type_id           { shift->_select_all('ReleaseGroupType') }
sub options_status_id         { shift->_select_all('ReleaseStatus') }
sub options_packaging_id      { shift->_select_all('ReleasePackaging') }
sub options_country_id        { shift->_select_all('Country') }

sub options_language_id {
    my ($self) = @_;

    my @sorted = sort { $a->{label} cmp $b->{label} } map {
        {
            'value' => $_->id,
            'label' => $_->{name},
            'class' => 'language',
            'data-frequency' => $_->{frequency},
        }
    } $self->ctx->model('Language')->get_all;

    return \@sorted;
}

sub options_script_id {
    my ($self) = @_;

    return [ map {
        {
            'value' => $_->id,
            'label' => $_->{name},
            'class' => 'script',
            'data-frequency' => $_->{frequency},
        }
    } $self->ctx->model('Script')->get_all ];
}


after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object)
    {
        if (defined $self->init_object->release_group)
        {
            $self->field ('type_id')->value ($self->init_object->release_group->type->id)
                if $self->init_object->release_group->type;
            $self->field ('type_id')->disabled (1);
        }

        my $max = @{ $self->init_object->labels } - 1;
        for (0..$max)
        {
            my $label = $self->init_object->labels->[$_]->label;

            my $name = $label ? $label->name : '';
            $self->field ('labels')->fields->[$_]->field ('name')->value ($name);
        }

        if (defined $self->init_object->latest_annotation)
        {
            $self->field ('annotation')->value ($self->init_object->latest_annotation->text);
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
