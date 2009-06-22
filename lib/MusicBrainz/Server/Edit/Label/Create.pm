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
sub edit_auto_edit { 1 }

has '+data' => (
    isa => Dict[
        name => Str,
        sort_name => Optional[Str],
        type => Optional[Int],
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
        country => Optional[Int],
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

sub create
{
    my ($class, $label, @args) = @_;
    return $class->new(data => $label, @args);
}

sub entities
{
    my $self = shift;
    return {
        label => [ $self->label_id ],
    };
}

override 'accept' => sub
{
    my $self = shift;
    my %data = %{ $self->data };
    $data{sort_name} ||= $data{name};

    my $label_data = MusicBrainz::Server::Data::Label->new(c => $self->c);
    my $label = $label_data->insert(\%data);

    $self->label($label);
    $self->label_id($label->id);
};


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

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;
