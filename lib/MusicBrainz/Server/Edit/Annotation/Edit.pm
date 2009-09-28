package MusicBrainz::Server::Edit::Annotation::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( enum );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit';

has '+data' => (
    isa => Dict[
        editor_id => Int,
        text => Str,
        changelog => Nullable[Str],
        entity_id => Int,
    ],
);

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

sub accept
{
    my $self = shift;
    my $model = $self->_annotation_model;
    $model->edit($self->data);
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
