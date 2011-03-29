package MusicBrainz::Server::Edit::Release::Move;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use MusicBrainz::Server::Translation qw( l ln );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { l('Change release group') }
sub edit_type { $EDIT_RELEASE_MOVE }

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

sub related_entities
{
    my $self = shift;
    return {
        release => [ $self->data->{release}{id} ],
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
    $self->c->model('Release')->update($self->data->{release}{id}, {
        release_group_id => $self->data->{new_release_group}{id}   
    });
    unless($self->c->model('ReleaseGroup')->in_use($self->data->{old_release_group}{id})) {
        $self->c->model('ReleaseGroup')->delete($self->data->{old_release_group}{id});
    }
}

1;
