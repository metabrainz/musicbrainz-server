package MusicBrainz::Server::Edit::Medium::Delete;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Medium::Util ':all';
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview',
     'MusicBrainz::Server::Edit::Medium::RelatedEntities',
     'MusicBrainz::Server::Edit::Medium',
     'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Medium';

sub edit_type { $EDIT_MEDIUM_DELETE }
sub edit_name { N_l('Remove medium') }
sub edit_kind { 'remove' }
sub medium_id { shift->data->{medium_id} }
sub edit_template { 'RemoveMedium' }

has '+data' => (
    isa => Dict[
        medium_id => Int,
        format_id => Nullable[Int],
        tracklist => Optional[ArrayRef[track()]],
        name => Str,
        position => Int,
        release_id => Int,
    ],
);

sub alter_edit_pending
{
    my $self = shift;
    return {
        'Medium' => [ $self->medium_id ],
        'Release' => [ $self->data->{release_id} ],
    };
}

sub foreign_keys
{
    my $self = shift;
    my %fk;

    $fk{Medium} = { $self->medium_id => [ 'MediumFormat', 'Release ArtistCredit' ] };
    $fk{MediumFormat} = { $self->data->{format_id} => [] } if $self->data->{format_id};
    $fk{Release} = { $self->data->{release_id} => [qw( ArtistCredit )] };

    tracklist_foreign_keys(\%fk, $self->data->{tracklist});

    return \%fk;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $format = $self->data->{format_id};

    my $loaded_medium = $loaded->{Medium}{ $self->medium_id };
    if ($loaded_medium && $self->is_open) {
        $self->c->model('Track')->load_for_mediums($loaded_medium);
        my @tracks = $loaded_medium->all_tracks;
        $self->c->model('ArtistCredit')->load(@tracks);
        $self->c->model('Recording')->load(@tracks);
    }

    my $medium = $loaded_medium //
                 Medium->new(
                     format => $format ? $loaded->{MediumFormat}{$format} : undef,
                     name => $self->data->{name},
                     position => $self->data->{position},
                     release_id => $self->data->{release_id},
                     release => $loaded->{Release}{ $self->data->{release_id} } //
                                Release->new(
                                    id => $self->data->{release_id},
                                ),
                 );

    return {
        medium => to_json_object($medium),
        tracks => to_json_array(display_tracklist($loaded, $self->data->{tracklist})),
    };
}

sub initialize
{
    my ($self, %args) = @_;

    my $medium = $args{medium} or die 'Missing required medium object';

    $self->c->model('Track')->load_for_mediums($medium);
    $self->c->model('ArtistCredit')->load($medium->all_tracks);

    $self->data({
        medium_id => $medium->id,
        format_id => $medium->format_id,
        tracklist => tracks_to_hash($medium->tracks),
        name => $medium->name,
        position => $medium->position,
        release_id => $medium->release_id,
    });
}

sub accept
{
    my $self = shift;

    # Build related entities *before* deleting this medium, so we know which
    # release/rg/etc to relate to. However, this does not need to run for
    # edits that are already inserted.
    if (!$self->created_time) {
        $self->related_entities;
    }

    $self->c->model('Medium')->delete($self->medium_id);
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{name} //= '';
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
