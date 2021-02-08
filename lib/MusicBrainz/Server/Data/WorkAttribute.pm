package MusicBrainz::Server::Data::WorkAttribute;

use Moose;
use namespace::autoclean;
use aliased 'MusicBrainz::Server::Entity::WorkAttribute';
use aliased 'MusicBrainz::Server::Entity::WorkAttributeType';

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';

sub _type { 'work_attribute' }

sub _table
{
    return 'work_attribute';
}

sub _columns
{
    return 'id, work_attribute_type AS type_id, ' .
           'work_attribute_type_allowed_value AS value_id, ' .
           'work_attribute_text AS value';
}

sub _column_mapping
{
    return {
        id          => 'id',
        type_id     => 'type_id',
        value_id    => 'value_id',
        value       => 'value',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::WorkAttribute';
}

sub load_for_works {
    my ($self, @works) = @_;

    @works = grep { scalar $_->all_attributes == 0 } @works;

    my @work_ids = map { $_->id } @works;

    my $attributes = $self->sql->select_list_of_hashes(
        'SELECT
           coalesce(
             work_attribute_type_allowed_value.value,
             work_attribute.work_attribute_text
           ) AS value,
           work,
           work_attribute.id AS id,
           work_attribute.work_attribute_type_allowed_value AS value_id,
           work_attribute_type_allowed_value.gid AS value_gid,
           work_attribute.work_attribute_type AS type_id
         FROM work_attribute
         LEFT JOIN work_attribute_type_allowed_value
           ON work_attribute_type_allowed_value.id =
                work_attribute.work_attribute_type_allowed_value
         WHERE work_attribute.work = any(?)',
        \@work_ids
    );

    my %work_map;
    for my $work (@works) {
        push @{ $work_map{$work->id} //= [] }, $work;
    }

    for my $attribute (@$attributes) {
        for my $work (@{ $work_map{$attribute->{work}} }) {
            $work->add_attribute(
                WorkAttribute->new(
                    id => $attribute->{id},
                    type_id => $attribute->{type_id},
                    value => $attribute->{value},
                    value_gid => $attribute->{value_gid},
                    value_id => $attribute->{value_id},
                )
            );
        }
    }

    $self->c->model('WorkAttributeType')->load(
        map { $_->all_attributes } @works
    );
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
