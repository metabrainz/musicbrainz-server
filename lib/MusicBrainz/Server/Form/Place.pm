package MusicBrainz::Server::Form::Place;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use List::UtilsBy qw( sort_by );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::CheckDuplicates';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-place' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'address' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1
);

has_field 'area_id'   => ( type => 'Hidden' );
has_field 'area'      => (
    type => '+MusicBrainz::Server::Form::Field::Area'
);

has_field 'coordinates' => (
    type => '+MusicBrainz::Server::Form::Field::Coordinates',
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

sub edit_field_names
{
    return qw( name type_id address area_id comment coordinates period.begin_date period.end_date period.ended );
}

sub options_type_id { select_options_tree(shift->ctx, 'PlaceType') }

sub dupe_model { shift->ctx->model('Place') }

sub filter_duplicates {
    my $self = shift;

    my $form_area = $self->ctx->model('Area')->get_by_id($self->field('area_id')->value);

    my @duplicates = @{ $self->duplicates };
    my @load_areas = $self->ctx->model('Area')->load(@duplicates);
    push @load_areas, $form_area if defined $form_area;
    $self->ctx->model('Area')->load_containment(@load_areas);

    # We require a disambiguation comment if no area is given, or if there
    # is a possible duplicate in the same area or lacking area information.
    return 1 unless defined $form_area;
    my $comment_is_required = 0;
    my $category = sub {
        my $a = shift->area;
        $comment_is_required = 1, return 0 unless defined $a;
        $comment_is_required = 1, return 1 if $a->id == $form_area->id;
        return 2 if $a->name eq $form_area->name;
        my $shares_level = sub {
            my $level = shift;
            return ($a->{"parent_$level"} // $a)->id == ($form_area->{"parent_$level"} // $form_area)->id;
        };
        return 3 if $shares_level->('city');
        return 4 if $shares_level->('subdivision');
        return 5 if $shares_level->('country');
        return 6;
    };
    @duplicates = sort_by { $category->($_) } @duplicates;

    $self->duplicates(\@duplicates);
    return $comment_is_required;
}

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
