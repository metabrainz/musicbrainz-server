package MusicBrainz::Server::Edit::Medium::RemoveDiscID;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_REMOVE_DISCID );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Translation qw ( N_l );
use MusicBrainz::Server::Edit::Utils qw( conditions_without_autoedit );

sub edit_name { N_l('Remove disc ID') }
sub edit_type { $EDIT_MEDIUM_REMOVE_DISCID }
sub edit_kind { 'remove' }

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';
with 'MusicBrainz::Server::Edit::Medium';

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::Release';

sub medium_id { shift->data->{medium}{id} }

has '+data' => (
    isa => Dict[
        medium       => Dict[
            id => Int,
            release => Dict[
                id => Int,
                name => Str,
            ]
        ],
        medium_cdtoc => Dict[
            cdtoc        => Dict[
                id => Int,
                toc => Str,
            ],
            id => Int,
        ]
    ]
);

has 'release_id' => (
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{medium}{release}{id} }
);

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;
    return conditions_without_autoedit($self->$orig(@args));
};

method initialize (%opts) {
    my $medium = delete $opts{medium} or die 'Missing "medium" parameter';
    my $cdtoc = delete $opts{cdtoc} or die 'Missing "cdtoc" parameter';

    unless ($medium->release) {
        $self->c->model('Release')->load($medium);
    }

    $opts{medium} = {
        id => $medium->id,
        release => {
            id => $medium->release_id,
            name => $medium->release->name
        }
    };

    $opts{medium_cdtoc} = {
        id => $cdtoc->id,
        cdtoc => {
            id => $cdtoc->cdtoc->id,
            toc => $cdtoc->cdtoc->toc
        }
    };

    $self->data(\%opts);
}

method alter_edit_pending
{
    return {
        MediumCDTOC => [ $self->data->{medium_cdtoc}{id} ],
    }
}

method foreign_keys
{
    my $release_id =

    return {
        Release => { $self->release_id => [ 'ArtistCredit' ] },
        Medium  => { $self->data->{medium}{id} => [ 'MediumFormat', 'Release' ] },
        CDTOC   => [ $self->data->{medium_cdtoc}{cdtoc}{id} ]
    }
}

method build_display_data ($loaded)
{
    return {
        release => $loaded->{Release}{ $self->release_id } ||
            Release->new(
                $self->data->{medium}{release}
            ),
        medium  => $loaded->{Medium}{ $self->data->{medium}{id} },
        cdtoc   => $loaded->{CDTOC}{ $self->data->{medium_cdtoc}{cdtoc}{id} }
            || CDTOC->new_from_toc($self->data->{medium_cdtoc}{cdtoc}{toc})
    }
}

override 'accept' => sub {
    my ($self) = @_;
    $self->c->model('MediumCDTOC')->delete(
        $self->data->{medium_cdtoc}{id}
    );
};

no Moose;
__PACKAGE__->meta->make_immutable;
