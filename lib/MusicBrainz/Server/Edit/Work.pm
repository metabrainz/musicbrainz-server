package MusicBrainz::Server::Edit::Work;
use List::UtilsBy qw( partition_by );
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Work') }

sub grouped_attributes_by_type {
    my ($self, $attributes) = @_;

    return [] unless @{ $attributes // [] };

    my $attribute_types = $self->c->model('WorkAttributeType')->get_by_ids(
        map { $_->{attribute_type_id} } @$attributes
    );

    my $attribute_values = $self->c->model('WorkAttributeTypeAllowedValue')->get_by_ids(
        grep { $_ } map { $_->{attribute_value_id} } @$attributes
    );

    return partition_by { $_->type->l_name } map {
        MusicBrainz::Server::Entity::WorkAttribute->new(
            type_id => $_->{attribute_type_id},
            type => $attribute_types->{$_->{attribute_type_id}},
            value => $_->{attribute_text} // $attribute_values->{$_->{attribute_value_id}}->value,
            value_id => $_->{attribute_value_id}
        )
    } @$attributes;
}

1;
