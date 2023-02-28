package MusicBrainz::Server::Edit::Medium::RemoveDiscID;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_REMOVE_DISCID );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

sub edit_name { N_l('Remove disc ID') }
sub edit_type { $EDIT_MEDIUM_REMOVE_DISCID }
sub edit_kind { 'remove' }
sub edit_template { 'RemoveDiscId' }

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';
with 'MusicBrainz::Server::Edit::Medium';
with 'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Medium';

sub medium_id { shift->data->{medium}{id} }
sub release_id { shift->data->{medium}{release}{id} }

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
    return {
        Release => { $self->release_id => [ 'ArtistCredit' ] },
        Medium  => { $self->data->{medium}{id} => [ 'MediumFormat', 'Release ArtistCredit' ] },
        CDTOC   => [ $self->data->{medium_cdtoc}{cdtoc}{id} ]
    }
}

method build_display_data ($loaded)
{
    return {
        medium => to_json_object(
            $loaded->{Medium}{ $self->data->{medium}{id} } //
            Medium->new(
                release_id => $self->release_id,
                release => $loaded->{Release}{ $self->release_id } //
                                    Release->new(
                                        id => $self->release_id,
                                        name => $self->data->{medium}{release}{name},
                                    ),
            ),
        ),
        cdtoc => to_json_object(
            $loaded->{CDTOC}{ $self->data->{medium_cdtoc}{cdtoc}{id} } ||
            CDTOC->new_from_toc($self->data->{medium_cdtoc}{cdtoc}{toc})
        ),
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
