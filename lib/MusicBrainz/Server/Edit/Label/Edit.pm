package MusicBrainz::Server::Edit::Label::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_EDIT }
sub edit_name { "Edit Label" }
sub entity_id { shift->label_id }
sub entity_model { 'Label' }

sub label_id { shift->data->{label} }

has 'label' => (
    isa => 'Label',
    is => 'rw'
);

sub entities
{
    my $self = shift;
    return {
        label => [ $self->label_id ],
    };
}

subtype 'LabelHash'
    => as Dict[
        name => Optional[Str],
        sort_name => Optional[Str],
        type_id => Optional[Maybe[Int]],
        label_code => Optional[Maybe[Int]],
        country_id => Optional[Maybe[Int]],
        comment => Optional[Maybe[Str]],
        begin_date => Optional[Dict[
            year => Int,
            month => Optional[Int],
            day => Optional[Int],
        ]],
        end_date => Optional[Dict[
            year => Int,
            month => Optional[Int],
            day => Optional[Int],
        ]],
    ];

has '+data' => (
    isa => Dict[
        label => Int,
        new => find_type_constraint('LabelHash'),
        old => find_type_constraint('LabelHash'),
    ]
);

sub _date_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return partial_date_to_hash($a->$attr); 
    };
}

sub _mapping
{
    return (
        begin_date => _date_closure('begin_date'),
        end_date => _date_closure('end_date'),
    );
}

sub initialize
{
    my ($self, %args) = @_;
    my $label = delete $args{label};
    die "You must specify the label object to edit" unless defined $label;

    $self->data({
        old => $self->_change_hash($label, keys %args),
        new => \%args,
        label => $label->id
    });
};

override 'accept' => sub
{
    my $self = shift;
    my $label_data = MusicBrainz::Server::Data::Label->new(c => $self->c);
    $label_data->update($self->label_id, $self->data->{new});
};

__PACKAGE__->meta->make_immutable;
__PACKAGE__->register_type;

no Moose;
1;
