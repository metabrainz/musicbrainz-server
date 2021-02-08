package MusicBrainz::Server::Form::Area;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-area' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'iso_3166_1' => (
    type => 'Repeatable',
);

has_field 'iso_3166_1.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_1',
);

has_field 'iso_3166_2' => (
    type => 'Repeatable',
);

has_field 'iso_3166_2.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_2',
);

has_field 'iso_3166_3' => (
    type => 'Repeatable',
);

has_field 'iso_3166_3.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_3',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

sub edit_field_names
{
    return qw( name comment type_id period.begin_date period.end_date period.ended iso_3166_1 iso_3166_2 iso_3166_3 );
}

sub options_type_id     { select_options_tree(shift->ctx, 'AreaType') }

sub validate {
    my ($self) = @_;

    for my $iso (qw( iso_3166_1 iso_3166_2 iso_3166_3 )) {
        $self->_unique_iso_code($iso);
    }


    return 1;
}

sub _unique_iso_code {
    my ($self, $iso_field) = @_;

    my $area_id = $self->init_object ? $self->init_object->id : 0;
    my $method = "get_by_$iso_field";
    my $container = $self->field($iso_field);

    if (
        my %areas = %{ $self->ctx->model('Area')->$method(@{ $container->value }) }
    ) {
        for my $f ($container->fields) {
            my $area_using_iso_code = $areas{$f->value} or next;
            if ($area_using_iso_code->id != $area_id) {
                $f->add_error(l('An area already exists with this ISO code'));
            }
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
