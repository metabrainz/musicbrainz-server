package MusicBrainz::Server::Edit::Release::EditArtist;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( all pairwise );
use MooseX::Types::Moose qw( Bool Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ARTIST );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Translation 'l';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { l('Change release quality') }
sub edit_type { $EDIT_RELEASE_ARTIST }
sub release_id { shift->data->{release_id} }

has '+data' => (
    isa => Dict[
        release_id => Int,
        update_tracklists => Bool,
        old_artist_credit => ArtistCreditDefinition,
        new_artist_credit => ArtistCreditDefinition
    ]
);

sub alter_edit_pending
{
    my $self = shift;
    return {
        Release => [ $self->release_ids ],
    }
}

sub initialize {
    my ($self, %opts) = @_;
    my $release = delete $opts{release} or die 'Missing release object';
    if (!$release->artist_credit) {
        $self->c->model('ArtistCredit')->load($release);
    }

    $self->data({
        release_id => $release->id,
        update_tracklists => $opts{update_tracklists},
        new_artist_credit => $opts{artist_credit},
        old_artist_credit => artist_credit_to_ref($release->artist_credit)
    });
    return $self;
}

sub accept {
    my $self = shift;

    my $new_ac_id = $self->c->model('ArtistCredit')->find_or_insert(
        @{ $self->data->{new_artist_credit} }
    );

    $self->c->model('Release')->update(
        $self->release_id, {
            artist_credit =>$new_ac_id
        });

    if ($self->data->{update_tracklists}) {
        my $release = $self->c->model('Release')->get_by_id($self->data->{release_id});
        $self->c->model('Medium')->load_for_releases($release);
        $self->c->model('Track')->load_for_tracklists(
            map { $_->tracklist } $release->all_mediums);

        for my $medium ($release->all_mediums) {
            $self->c->model('Medium')->update(
                $medium->id,
                {
                    tracklist_id => $self->c->model('Tracklist')->find_or_insert([
                        map +{
                            position => $_->position,
                            name => $_->name,
                            artist_credit => $new_ac_id,
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
