package MusicBrainz::Server::Edit::Medium::RemoveDiscID;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_REMOVE_DISCID );
use MusicBrainz::Server::Translation qw( l ln );

sub edit_name { l('Remove disc ID') }
sub edit_type { $EDIT_MEDIUM_REMOVE_DISCID }

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';

sub medium_id { shift->data->{medium_id} }

has '+data' => (
    isa => Dict[
        cdtoc_id     => Int,
        medium_id    => Int,
        medium_cdtoc => Int,
    ]
);

has 'release_id' => (
    is => 'rw',
    lazy_build => 1
);

method _build_release_id {
    return $self->c->model('Medium')
        ->get_by_id($self->medium_id)
            ->release_id;
}

method alter_edit_pending
{
    return {
        MediumCDTOC => [ $self->data->{medium_cdtoc} ],
    }
}

method foreign_keys
{
    my $release_id =

    return {
        Release => { $self->release_id => [ 'ArtistCredit' ] },
        CDTOC   => [ $self->data->{cdtoc_id} ]
    }
}

method build_display_data ($loaded)
{
    return {
        release => $loaded->{Release}{ $self->release_id },
        cdtoc   => $loaded->{CDTOC}{ $self->data->{cdtoc_id} },
    }
}

override 'accept' => sub {
    my ($self) = @_;
    $self->c->model('MediumCDTOC')->delete(
        $self->data->{cdtoc_id},
        $self->data->{medium_id},
    );
};

no Moose;
__PACKAGE__->meta->make_immutable;
