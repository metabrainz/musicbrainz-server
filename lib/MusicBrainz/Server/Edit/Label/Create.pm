package MusicBrainz::Server::Edit::Label::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use Moose::Util::TypeConstraints qw( subtype find_type_constraint );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );

extends 'MusicBrainz::Server::Edit';

sub edit_name { "Create Label" }
sub edit_type { $EDIT_LABEL_CREATE }

sub related_entities { { label => [ shift->label_id ] } }
sub alter_edit_pending { { Label => [ shift->label_id ] } }

has '+data' => (
    isa => Dict[
        name => Str,
        sort_name => Optional[Str],
        type_id => Optional[Int],
        label_code => Optional[Int],
        begin_date => Optional[Dict[ 
            year => Int,
            month => Optional[Int],
            day => Optional[Int]
        ]],
        end_date => Optional[Dict[ 
            year => Int,
            month => Optional[Int],
            day => Optional[Int]
        ]],
        country_id => Optional[Int],
        comment => Optional[Str],
    ]
);

sub foreign_keys
{
    my $self = shift;

    return {
        LabelType => [ $self->data->{type_id} ],
        Country   => [ $self->data->{country_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = {
        name       => $self->data->{name},
        sort_name  => $self->data->{sort_name},
        type       => $loaded->{LabelType}->{ $self->data->{type_id} },
        label_code => $self->data->{label_code},
        country    => $loaded->{Country}->{ $self->data->{country_id} },
        comment    => $self->data->{comment},
        begin_date => partial_date_from_row($self->data->{begin_date}),
        end_date   => partial_date_from_row($self->data->{end_date}),
    };
}

has 'label_id' => (
    isa => 'Int',
    is => 'rw'
);

has 'label' => (
    isa => 'Label',
    is => 'rw'
);

sub insert
{
    my $self = shift;
    my %data = %{ $self->data };
    $data{sort_name} ||= $data{name};

    my $label = $self->c->model('Label')->insert(\%data);

    $self->label($label);
    $self->label_id($label->id);
}

sub reject
{
    my $self = shift;
    $self->c->model('Label')->delete($self->label_id);
}

# label_id is handled separately, as it should not be copied if the edit is cloned
# (a new different label_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{label_id} = $self->label_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->label_id(delete $hash->{label_id});
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;
