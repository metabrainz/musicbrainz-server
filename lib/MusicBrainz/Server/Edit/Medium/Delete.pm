package MusicBrainz::Server::Edit::Medium::Delete;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Medium::Util ':all';
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';
with 'MusicBrainz::Server::Edit::Medium';

sub edit_type { $EDIT_MEDIUM_DELETE }
sub edit_name { l('Remove medium') }
sub medium_id { shift->data->{medium_id} }

sub alter_edit_pending { { Medium => [ shift->medium_id ] } }

has '+data' => (
    isa => Dict[
        medium_id => Int,
        format_id => Nullable[Int],
        tracklist => Optional[ArrayRef[track()]],
        name => Nullable[Str],
        position => Int,
        release_id => Int
    ]
);

sub foreign_keys
{
    my $self = shift;
    my %fk;

    $fk{MediumFormat} = { $self->data->{format_id} => [] };
    $fk{Release} = { $self->data->{release_id} => [qw( ArtistCredit )] };

    tracklist_foreign_keys (\%fk, $self->data->{tracklist});

    return \%fk;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        format => $loaded->{MediumFormat}->{ $self->data->{format_id} },
        release => $loaded->{Release}->{ $self->data->{release_id} },
        tracklist => display_tracklist ($loaded, $self->data->{tracklist}),
        name => $self->data->{name},
        position => $self->data->{position},
    }
}

sub initialize
{
    my ($self, %args) = @_;

    my $medium = $args{medium} or die 'Missing required medium object';

    $self->c->model('Tracklist')->load ($medium);
    $self->c->model('Track')->load_for_tracklists ($medium->tracklist);
    $self->c->model('ArtistCredit')->load ($medium->tracklist->all_tracks);

    $self->data({
        medium_id => $medium->id,
        format_id => $medium->format_id,
        tracklist => tracks_to_hash($medium->tracklist->tracks),
        name => $medium->name,
        position => $medium->position,
        release_id => $medium->release_id,
    });
}

sub accept
{
    my $self = shift;
    $self->c->model('Medium')->delete($self->medium_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
