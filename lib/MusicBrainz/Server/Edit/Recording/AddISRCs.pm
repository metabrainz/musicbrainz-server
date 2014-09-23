package MusicBrainz::Server::Edit::Recording::AddISRCs;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Str Int );
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Edit::Exceptions;

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};
with 'MusicBrainz::Server::Edit::Recording';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::ISRC';

sub edit_type { $EDIT_RECORDING_ADD_ISRCS }
sub edit_name { N_l('Add ISRCs') }
sub edit_kind { 'add' }

sub recording_ids { map { $_->{recording}{id} } @{ shift->data->{isrcs} } }

has '+data' => (
    isa => Dict[
        isrcs => ArrayRef[Dict[
            isrc      => Str,
            recording => Dict[
                id => Int,
                name => Str
            ],
            source    => Nullable[Int],
        ]],
        client_version => Nullable[Str]
    ]
);

sub initialize
{
    my ($self, %opts) = @_;
    my @isrcs = $self->c->model('ISRC')->filter_additions(@{ $opts{isrcs} });

    if (@isrcs == 0) {
        MusicBrainz::Server::Edit::Exceptions::NoChanges->throw;
    }
    else {
        $self->data({
            isrcs => \@isrcs,
            client_version => $opts{client_version}
        });
    }
}

sub _build_related_entities
{
    my $self = shift;
    return {
        recording => [ uniq map {
            $_->{recording}{id}
        } @{ $self->data->{isrcs} } ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { map {
            $_->{recording}{id} => ['ArtistCredit']
        } @{ $self->data->{isrcs} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        additions => [
            map { +{
                recording => $loaded->{Recording}{ $_->{recording}{id} }
                    || Recording->new( name => $_->{recording}{name} ),
                isrc      => ISRC->new( isrc => $_->{isrc} ),
                source    => $_->{source}
            } } @{ $self->data->{isrcs} }
        ]
    }
}

sub accept
{
    my $self = shift;
    $self->c->model('ISRC')->insert(
        map +{
            recording_id => $_->{recording}{id},
            isrc => $_->{isrc},
            source => $_->{source}
        }, @{ $self->data->{isrcs} }
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;
