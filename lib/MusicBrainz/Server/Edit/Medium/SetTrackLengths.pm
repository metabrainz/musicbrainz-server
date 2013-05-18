package MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Medium';

sub edit_name { N_l('Set track lengths') }
sub edit_type { $EDIT_SET_TRACK_LENGTHS }

has '+data' => (
    isa => Dict[
        tracklist_id => Nullable[Int],
        medium_id => Nullable[Int],
        cdtoc => Dict[
            id => Int,
            toc => Str
        ],
        affected_releases => ArrayRef[Dict[
            id => Int,
            name => Str,
        ]],
        length => Dict[
            # Old track lengths may be undef
            old => ArrayRef[Nullable[Int]],

            # But new tracks must be set if we have a toc
            new => ArrayRef[Int],
        ]
    ]
);

sub release_ids {
    my $self = shift;
    return map { $_->{id} } @{ $self->data->{affected_releases} };
}

sub foreign_keys {
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->release_ids
        },
        CDTOC => [ $self->data->{cdtoc}{id} ]
    }
}

sub build_display_data {
    my ($self, $loaded) = @_;
    return {
        cdtoc => $loaded->{CDTOC}{ $self->data->{cdtoc}{id} }
            || CDTOC->new_from_toc( $self->data->{cdtoc}{toc} ),
        releases => [
            map {
                $loaded->{Release}{ $_->{id} } ||
                    Release->new( name => $_->{name} )
            } @{ $self->data->{affected_releases} }
        ],
        length => {
            map { $_ => $self->data->{length}{$_} } qw( old new )
        }
    }
}

sub initialize {
    my ($self, %opts) = @_;
    my $medium_id = $opts{medium_id}
        or die 'Missing medium ID';

    my $cdtoc_id = $opts{cdtoc_id}
        or die 'Missing CDTOC ID';

    my $medium = $self->c->model('Medium')->get_by_id ($medium_id);

    $self->c->model('Release')->load($medium);
    $self->c->model('ArtistCredit')->load($medium->release);
    $self->c->model('Track')->load_for_mediums($medium);

    my $cdtoc = $self->c->model('CDTOC')->get_by_id($cdtoc_id);

    $self->data({
        tracklist_id => undef,
        medium_id => $medium_id,
        cdtoc => {
            id => $cdtoc_id,
            toc => $cdtoc->toc
        },
        affected_releases => [ map +{
            id => $_->id,
            name => $_->name
        }, $medium->release ] ,
        length => {
            old => [ map { $_->length } $medium->all_tracks ],
            new => [ map { $_->{length_time} } @{ $cdtoc->track_details } ],
        }
    })
}

sub accept {
    my $self = shift;

    my $medium_id = $self->data->{medium_id};
    if (!$self->c->model('Medium')->get_by_id($medium_id)) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The medium to set track times no longer exists. It may have '.
            'been merged into another identical tracklist, or been changed '.
            'since this edit was entered.'
        );
    }

    $self->c->model('Medium')->set_lengths_to_cdtoc(
        $medium_id, $self->data->{cdtoc}{id});
}

__PACKAGE__->meta->make_immutable;
1;
