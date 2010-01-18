package MusicBrainz::Server::Edit::Label::Edit;
use Moose;

use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash Nullable );
use MusicBrainz::Server::Edit::Utils qw( date_closure changed_relations changed_display_data );

extends 'MusicBrainz::Server::Edit::Generic::Edit';

sub edit_type { $EDIT_LABEL_EDIT }
sub edit_name { "Edit label" }
sub _edit_model { 'Label' }
sub label_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        label_code => Nullable[Int],
        country_id => Nullable[Int],
        comment    => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
    ];
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        new => change_fields(),
        old => change_fields(),
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        LabelType => 'type_id',
        Country   => 'country_id',
    );

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name       => 'name',
        sort_name  => 'sort_name',
        type       => [ qw( type_id LabelType ) ],
        label_code => 'label_code',
        comment    => 'comment',
        country    => [ qw( country_id Country ) ],
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    for my $period (qw( begin end )) {
        my $field = $period . '_date';
        if (exists $self->data->{new}{$field}) {
            $data->{$field} = {
                new => partial_date_from_row($self->data->{new}{$field}),
                old => partial_date_from_row($self->data->{old}{$field}),
            };
        }
    }

    return $data;
}

sub _mapping
{
    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
