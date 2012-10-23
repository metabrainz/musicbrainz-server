package MusicBrainz::Server::Edit::Release::EditArtist;
use Moose;
use namespace::autoclean;
use Data::Compare;

use List::MoreUtils qw( all pairwise );
use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ARTIST );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    clean_submitted_artist_credits
    load_artist_credit_definitions
    verify_artist_credits
);
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { N_l('Edit release artist') }
sub edit_type { $EDIT_RELEASE_ARTIST }
sub release_id { shift->data->{release}{id} }

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        update_tracklists => Bool,
        old_artist_credit => ArtistCreditDefinition,
        new_artist_credit => ArtistCreditDefinition
    ]
);

around _build_related_entities => sub {
    my ($orig, $self) = @_;

    my $related = $self->$orig;
    if (exists $self->data->{new_artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new_artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old_artist_credit});
        push @{ $related->{artist} }, keys(%new), keys(%old);
    }

    return $related;
};


sub alter_edit_pending
{
    my $self = shift;
    return {
        Release => [ $self->release_ids ],
    }
}

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};

    if (exists $self->data->{new_artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_})
            } qw( new_artist_credit old_artist_credit )
        };
    }

    $relations->{Release} = {
        $self->data->{release}{id} => [ 'ArtistCredit' ]
    };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = {};

    if (exists $self->data->{new_artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new_artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old_artist_credit})
        }
    }

    $data->{update_tracklists} = $self->data->{update_tracklists};
    $data->{release} = $loaded->{Release}{ $self->data->{release}{id} }
        || Release->new( name => $self->data->{release}{name} );

    return $data;
}

sub initialize {
    my ($self, %opts) = @_;
    my $release = delete $opts{release} or die 'Missing release object';
    if (!$release->artist_credit) {
        $self->c->model('ArtistCredit')->load($release);
    }

    my $new = clean_submitted_artist_credits ($opts{artist_credit});
    my $old = clean_submitted_artist_credits ($release->artist_credit);

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if Compare ($old, $new);

    $self->data({
        release => {
            id => $release->id,
            name => $release->name
        },
        update_tracklists => $opts{update_tracklists},
        new_artist_credit => $new,
        old_artist_credit => $old,
    });
    return $self;
}

sub accept {
    my $self = shift;

    verify_artist_credits($self->c, $self->data->{new_artist_credit});

    my $release = $self->c->model('Release')->get_by_id($self->data->{release}{id});

    if (!$release) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This edit cannot be applied, as the release being edited no longer exists.'
        );
    }

    my $old_ac_id = $release->artist_credit_id;

    my $new_ac_id = $self->c->model('ArtistCredit')->find_or_insert(
        $self->data->{new_artist_credit}
    );

    $self->c->model('Release')->update(
        $self->release_id, {
            artist_credit =>$new_ac_id
        });


    if ($self->data->{update_tracklists}) {
        $self->c->model('Medium')->load_for_releases($release);
        $self->c->model('Track')->load_for_tracklists(
            map { $_->tracklist } $release->all_mediums);
        $self->c->model('ArtistCredit')->load(
            map { $_->tracklist->all_tracks } $release->all_mediums);

        for my $medium ($release->all_mediums) {
            $self->c->model('Medium')->update(
                $medium->id,
                {
                    tracklist_id => $self->c->model('Tracklist')->find_or_insert([
                        map +{
                            position => $_->position,
                            name => $_->name,
                            artist_credit => $_->artist_credit_id != $old_ac_id
                                ? artist_credit_to_ref($_->artist_credit, [])
                                : $self->data->{new_artist_credit},
                            recording_id => $_->recording_id,
                            length => $_->length
                        }, $medium->tracklist->all_tracks
                    ])->id
                }
            );
        }
    }
}

1;
