package MusicBrainz::Server::Form::ReleaseEditor::Information;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Form::Step';

# Release information
has_field 'name'             => ( type => 'Text', required => 1, label => l('Title') );
has_field 'various_artists'  => ( type => 'Checkbox'  );
has_field 'release_group_id' => ( type => 'Hidden'    );

has_field 'release_group' => ( type => 'Compound'    );
has_field 'release_group.name' => ( type => 'Text'    );

has_field 'artist_credit'    => ( type => '+MusicBrainz::Server::Form::Field::ArtistCredit', required => 1, allow_unlinked => 1 );
has_field 'type_id'          => ( type => 'Select'    );
has_field 'status_id'        => ( type => 'Select'    );
has_field 'language_id'      => ( type => 'Select'    );
has_field 'script_id'        => ( type => 'Select'    );

# Release event
has_field 'date'             => ( type => '+MusicBrainz::Server::Form::Field::PartialDate', not_nullable => 1 );
has_field 'country_id'       => ( type => 'Select'    );
has_field 'packaging_id'     => ( type => 'Select'    );

has_field 'labels'           => ( type => 'Repeatable' );
has_field 'labels.catalog_number' => ( type => 'Text' );
has_field 'labels.deleted'   => ( type => 'Checkbox' );
has_field 'labels.label_id'  => ( type => 'Text' );
has_field 'labels.name'      => ( type => 'Text' );

has_field 'barcode'          => ( type => '+MusicBrainz::Server::Form::Field::Barcode' );
has_field 'barcode_confirm'  => ( type => 'Checkbox'  );

# Additional information
has_field 'annotation'       => ( type => 'TextArea'  );
has_field 'comment'          => ( type => 'Text', maxlength => 255 );


sub options_type_id           { shift->_select_all('ReleaseGroupType') }
sub options_status_id         { shift->_select_all('ReleaseStatus') }
sub options_packaging_id      { shift->_select_all('ReleasePackaging') }
sub options_country_id        { shift->_select_all('Country') }

sub options_language_id {
    my ($self) = @_;

    # group list of languages in <optgroups>.
    # most frequently used languages have hardcoded value 2.
    # languages which shouldn't be shown have hardcoded value 0.

    # FIXME: optgroups need to go through gettext. --warp.

    my $frequent = 2;
    my $skip = 0;

    my @sorted = sort { $a->{label} cmp $b->{label} } map {
        {
            'value' => $_->id,
            'label' => $_->{name},
            'class' => 'language',
            'optgroup' => $_->{frequency} eq $frequent ? 'Frequently used' : 'Other',
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $self->ctx->model('Language')->get_all;

    return \@sorted;
}

sub options_script_id {
    my ($self) = @_;

    # group list of scripts in <optgroups>.
    # most frequently used scripts have hardcoded value 4.
    # scripts which shouldn't be shown have hardcoded value 1.

    # FIXME: optgroups need to go through gettext. --warp.

    my $frequent = 4;
    my $skip = 1;

    return [ map {
        {
            'value' => $_->id,
            'label' => $_->{name},
            'class' => 'script',
            'optgroup' => $_->{frequency} eq $frequent ? 'Frequently used' : 'Other',
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $self->ctx->model('Script')->get_all ];
}

sub validate {
    my $self = shift;

    unless (!defined $self->field('barcode')->value ||
            $self->field('barcode')->value == '' ||
            MusicBrainz::Server::Validation::IsValidEAN ($self->field('barcode')->value) ||
            $self->field('barcode_confirm')->value == 1)
    {
        $self->field('barcode')->add_error (
            l("This barcode is invalid, please check that you've correctly entered the barcode."));
    }
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

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
