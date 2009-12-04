package MusicBrainz::Server::Edit::Label::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Edit::Utils qw( date_closure changed_relations changed_display_data );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash Nullable );
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_LABEL_EDIT }
sub edit_name { "Edit Label" }

sub alter_edit_pending { { Label => [ shift->label_id ] } }
sub related_entities { { label => [ shift->label_id ] } }

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{label} }
);

has 'label' => (
    isa => 'Label',
    is => 'rw'
);

subtype 'LabelHash'
    => as Dict[
        name => Optional[Str],
        sort_name => Optional[Str],
        type_id => Nullable[Int],
        label_code => Nullable[Int],
        country_id => Nullable[Int],
        comment => Nullable[Str],
        begin_date => Optional[PartialDateHash],
        end_date => Optional[PartialDateHash],
    ];

has '+data' => (
    isa => Dict[
        label => Int,
        new => find_type_constraint('LabelHash'),
        old => find_type_constraint('LabelHash'),
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

sub initialize
{
    my ($self, %args) = @_;
    my $label = delete $args{label};
    die "You must specify the label object to edit" unless defined $label;

    $self->data({
        label => $label->id,
        $self->_change_data($label, %args)
    });
};

override 'accept' => sub
{
    my $self = shift;
    $self->c->model('Label')->update($self->label_id, $self->data->{new});
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;
