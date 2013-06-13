package MusicBrainz::Server::Edit::Historic::MoveReleaseToRG;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { N_l('Change release group (historic)') }
sub edit_type { $EDIT_RELEASE_MOVE }
sub edit_template { 'historic/move_release_to_rg' }

sub release_id { shift->data->{release}{id} }
sub release_ids { shift->release_id }

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        old_release_group => Dict[
            id => Int,
            name => Str
        ],
        new_release_group => Dict[
            id => Int,
            name => Str
        ]
    ]
);

sub alter_edit_pending
{
    my $self = shift;
    return {
        Release => [ $self->data->{release}{id} ],
    }
}

sub _build_related_entities
{
    my $self = shift;

    my @releases = values %{ $self->c->model('Release')->get_by_ids($self->data->{release}{id}) };
    my @groups = values %{ $self->c->model('ReleaseGroup')->get_by_ids($self->data->{old_release_group}{id},
                                                                       $self->data->{new_release_group}{id}) };

    $self->c->model('ArtistCredit')->load(@releases, @groups);

    return {
        artist => [
            uniq map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @releases, @groups
        ],
        release =>       [ uniq map { $_->id } @releases ],
        release_group => [ uniq map { $_->id } @groups ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { $self->data->{release}{id} => [ 'ArtistCredit' ] },
        ReleaseGroup => {
            $self->data->{old_release_group}{id} => [ 'ArtistCredit' ],
            $self->data->{new_release_group}{id} => [ 'ArtistCredit' ],
        },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        release => $loaded->{Release}->{ $self->data->{release}{id} }
            || Release->new( name => $self->data->{release}{name} ),
        old_group => $loaded->{ReleaseGroup}->{ $self->data->{old_release_group}{id} }
            || ReleaseGroup->new( name => $self->data->{old_release_group}{name} ),
        new_group => $loaded->{ReleaseGroup}->{ $self->data->{new_release_group}{id} }
            || ReleaseGroup->new( name => $self->data->{new_release_group}{name} )
    }
}

sub initialize
{
    my ($self, %opts) = @_;

    my $release = $opts{release} or die 'No release object';
    my $release_group = $opts{new_release_group} or die 'No new release group';

    $self->data({
        release => {
            id => $release->id,
            name => $release->name
        },
        old_release_group => {
            id => $release->release_group_id,
            name => $release->release_group->name
        },
        new_release_group => {
            id => $release_group->id,
            name => $release_group->name
        }
    });
}

sub accept
{
    my $self = shift;
    my $target = $self->c->model('ReleaseGroup')->get_by_id($self->data->{new_release_group}{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The destination release group no longer exists'
        );

    $self->c->model('Release')->update($self->data->{release}{id}, {
        release_group_id => $target->id
    });
    unless($self->c->model('ReleaseGroup')->in_use($self->data->{old_release_group}{id})) {
        $self->c->model('ReleaseGroup')->delete($self->data->{old_release_group}{id});
    }
}

1;
