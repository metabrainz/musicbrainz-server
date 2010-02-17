package MusicBrainz::Server::Edit::Annotation::Edit;
use Moose;
use MooseX::ABC;

use Moose::Util::TypeConstraints qw( enum );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit';

has '+data' => (
    isa => Dict[
        editor_id => Int,
        text      => Nullable[Str],
        changelog => Nullable[Str],
        entity_id => Int,
    ],
);

has 'annotation_id' => (
    isa => 'Int',
    is => 'rw',
);

sub build_display_data
{
    my $self = shift;
    return {
        changelog     => $self->data->{changelog},
        annotation_id => $self->annotation_id
    };
}

sub edit_conditions
{
    my $conditions = {
        duration      => 0,
        votes         => 0,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1,
    };
    return {
        $QUALITY_LOW    => $conditions,
        $QUALITY_NORMAL => $conditions,
        $QUALITY_HIGH   => $conditions,
    };
}

sub insert
{
    my $self = shift;
    my $model = $self->_annotation_model;
    my $id = $model->edit($self->data);
    $self->annotation_id($id);
}

sub _annotation_model { die 'Not implemented' }

sub initialize
{
    my ($self, %opts) = @_;
    $self->data({
        %opts,
        editor_id => $self->editor_id,
    });
}

override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{annotation_id} = $self->annotation_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->annotation_id(delete $hash->{annotation_id});
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
