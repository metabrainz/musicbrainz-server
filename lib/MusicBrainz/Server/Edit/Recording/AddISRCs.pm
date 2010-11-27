package MusicBrainz::Server::Edit::Recording::AddISRCs;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Str Int );
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS
                                       :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};

sub edit_type { $EDIT_RECORDING_ADD_ISRCS }
sub edit_name { l('Add ISRCs') }

sub recording_ids { map { $_->{recording_id} } @{ shift->data->{isrcs} } }

has '+data' => (
    isa => Dict[
        isrcs => ArrayRef[Dict[
            isrc         => Str,
            recording_id => Int,
            source       => Nullable[Int],
        ]]
    ]
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

sub related_entities
{
    my $self = shift;
    return {
        recording => [ uniq map {
            $_->{recording_id}
        } @{ $self->data->{isrcs} } ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { map {
            $_->{recording_id} => ['ArtistCredit']
        } @{ $self->data->{isrcs} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        additions => [
            map { +{
                recording => $loaded->{Recording}{ $_->{recording_id} },
                isrc      => $_->{isrc},
                source    => $_->{source}
            } } @{ $self->data->{isrcs} }
        ]
    }
}

sub accept
{
    my $self = shift;
    $self->c->model('ISRC')->insert(
        @{ $self->data->{isrcs} }
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;
