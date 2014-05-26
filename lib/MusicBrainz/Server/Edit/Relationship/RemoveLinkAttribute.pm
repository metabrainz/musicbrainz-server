package MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( Str Int );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { N_l('Remove relationship attribute') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE }

has '+data' => (
    isa => Dict[
        name        => Str,
        description => Nullable[Str],
        id          => Int,
        parent_id   => Nullable[Int],
        child_order => Optional[Str]
    ]
);

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->delete($self->data->{id})
};

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

sub allow_auto_edit { 1 }

no Moose;
__PACKAGE__->meta->make_immutable;
