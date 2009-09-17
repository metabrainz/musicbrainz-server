package MusicBrainz::Server::Edit::Label::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use Moose::Util::TypeConstraints qw( subtype find_type_constraint );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Edit';

sub edit_name { "Create Label" }
sub edit_type { $EDIT_LABEL_CREATE }

sub related_entities { { label => [ shift->label_id ] } }
sub alter_edit_pending { { Label => [ shift->label_id ] } }
sub models { [qw( Label ) ] }

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
