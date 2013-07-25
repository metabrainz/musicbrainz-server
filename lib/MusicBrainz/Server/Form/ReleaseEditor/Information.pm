package MusicBrainz::Server::Form::ReleaseEditor::Information;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Form::Utils qw( language_options script_options );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_ean );

extends 'MusicBrainz::Server::Form::Step';

# Slightly hackish, but lets us know if we're editing an existing release or not
has_field 'id'               => ( type => 'Integer' );

# Release information
has_field 'name'             => ( type => 'Text', required => 1, label => l('Title') );
has_field 'release_group_id' => ( type => 'Hidden'    );

has_field 'release_group'    => ( type => 'Compound'    );
has_field 'release_group.name' => ( type => 'Text'    );

has_field 'artist_credit'    => ( type => '+MusicBrainz::Server::Form::Field::ArtistCredit', required => 1, allow_unlinked => 1 );
has_field 'primary_type_id'  => ( type => 'Select'    );
has_field 'secondary_type_ids' => ( type => 'Select', multiple => 1 );
has_field 'status_id'        => ( type => 'Select'    );
has_field 'language_id'      => ( type => 'Select'    );
has_field 'script_id'        => ( type => 'Select'    );

# Release events
has_field 'events' => (
    type => 'Repeatable'
);
has_field 'events.date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
    not_nullable => 1
);
has_field 'events.country_id' => (
    type => 'Select'
);
has_field 'events.deleted' => (
    type => 'Checkbox'
);

has_field 'packaging_id'     => ( type => 'Select'    );

has_field 'labels'           => ( type => 'Repeatable' );
has_field 'labels.catalog_number' => ( type => 'Text' );
has_field 'labels.deleted'   => ( type => 'Checkbox' );
has_field 'labels.label_id'  => ( type => 'Text' );
has_field 'labels.name'      => ( type => 'Text' );

has_field 'barcode'          => ( type => '+MusicBrainz::Server::Form::Field::Barcode' );
has_field 'barcode_confirm'  => ( type => 'Checkbox'  );
has_field 'no_barcode'       => ( type => 'Checkbox'  ); # release doesn't have a barcode.

# Additional information
has_field 'annotation'       => ( type => 'TextArea'  );
has_field 'comment'          => ( type => '+MusicBrainz::Server::Form::Field::Comment', maxlength => 255 );

sub options_primary_type_id   { shift->_select_all('ReleaseGroupType') }
sub options_secondary_type_ids { shift->_select_all('ReleaseGroupSecondaryType') }
sub options_status_id         { shift->_select_all('ReleaseStatus') }
sub options_packaging_id      { shift->_select_all('ReleasePackaging') }
sub options_events_country_id { shift->_select_all('CountryArea') }

sub options_language_id       { return language_options (shift->ctx); }
sub options_script_id         { return script_options (shift->ctx); }

sub validate {
    my $self = shift;

    my $current_release = $self->init_object //
        $self->field('id')->value ?
        $self->ctx->model('Release')->get_by_id($self->field('id')->value) :
        undef;
    unless (!defined $self->field('barcode')->value ||
            $self->field('barcode')->value eq '' ||
            ($current_release && $current_release->barcode eq $self->field('barcode')->value) ||
            is_valid_ean ($self->field('barcode')->value) ||
            $self->field('barcode_confirm')->value == 1)
    {
        $self->field('barcode')->add_error (
            l("This barcode is invalid, please check that you've correctly entered the barcode."));
    }

    my @active_release_events = grep { !$_->field('deleted')->value }
        @{ $self->field('events')->fields };

    # Countries can only be used once
    my %witnessed_countries;
    for my $event (
        grep { $_->field('country_id')->value } @active_release_events
    ) {
        my $field = $event->field('country_id');
        $field->add_error(l('You cannot use the same country more than once'))
            if (++$witnessed_countries{$field->value} > 1);
    }

    # A release_group_id *must* be present if we're editing an existing release.
    $self->field('release_group.name')->add_error(
        l('You must select an existing release group. If you wish to move this release,
           use the "change release group" action from the sidebar.')
    ) if (!$self->field('release_group_id')->value &&
           $self->field('id')->value);
}

after 'BUILD' => sub {
    my ($self) = @_;

    if (defined $self->init_object)
    {
        $self->field ('barcode')->value ($self->init_object->barcode->code);

        $self->field ('no_barcode')->value ($self->init_object->barcode->code eq '')
            if defined $self->init_object->barcode->code;

        if (defined $self->init_object->release_group)
        {
            $self->field ('primary_type_id')->value ($self->init_object->release_group->primary_type->id)
                if $self->init_object->release_group->primary_type;
            $self->field ('primary_type_id')->disabled (1);

            $self->field ('secondary_type_ids')->value ([ map { $_->id } $self->init_object->release_group->all_secondary_types ]);
            $self->field ('secondary_type_ids')->disabled (1);
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
