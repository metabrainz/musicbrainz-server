package MusicBrainz::Server::Edit::Annotation::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( enum );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( :expire_action :quality );

extends 'MusicBrainz::Server::Edit';

has '+data' => (
    isa => Dict[
        editor_id => Int,
        text => Str,
        changelog => Str,
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
    my %data = %{ $self->data };
    my $model = $self->_annotation_model;
    # We have to remap this, as annotation wants to see 'artist_id' for example, not 'entity_id'
    $data{ $model->type . '_id' } = delete $data{entity_id};
    $model->edit(\%data);
}

sub _annotation_model { die 'Not implemented' }

sub initialize
{
    my ($self, %opts) = @_;
    $opts{entity_id} = delete $opts{ $self->_annotation_model->type . '_id' };
    $self->data({
        %opts,
        editor_id => $self->editor_id,
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
