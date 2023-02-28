package MusicBrainz::Server::Form::Artist;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::IPI';
with 'MusicBrainz::Server::Form::Role::ISNI';
with 'MusicBrainz::Server::Form::Role::Relationships';

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

has_field 'area_id' => ( type => 'Hidden' );
has_field 'area' => (
    type => '+MusicBrainz::Server::Form::Field::Area'
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'begin_area_id' => ( type => 'Hidden' );
has_field 'begin_area' => (
    type => '+MusicBrainz::Server::Form::Field::Area'
);

has_field 'end_area_id' => ( type => 'Hidden' );
has_field 'end_area' => (
    type => '+MusicBrainz::Server::Form::Field::Area'
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

sub edit_field_names
{
    return qw( name sort_name type_id gender_id area_id begin_area_id end_area_id
               period.begin_date period.end_date period.ended comment
               ipi_codes isni_codes );
}

sub options_gender_id   { select_options_tree(shift->ctx, 'Gender') }
sub options_type_id     { select_options_tree(shift->ctx, 'ArtistType') }

sub validate {
    my ($self) = @_;

    if ($self->field('type_id')->value &&
        $self->field('type_id')->value == 2) {
        if ($self->field('gender_id')->value) {
            $self->field('gender_id')->add_error(l('Group artists cannot have a gender.'));
        }
    }

    if ($self->field('type_id')->value &&
        $self->field('type_id')->value == 5) {
        if ($self->field('gender_id')->value) {
            $self->field('gender_id')->add_error(l('Orchestras cannot have a gender.'));
        }
    }

    if ($self->field('type_id')->value &&
        $self->field('type_id')->value == 6) {
        if ($self->field('gender_id')->value) {
            $self->field('gender_id')->add_error(l('Choirs cannot have a gender.'));
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
