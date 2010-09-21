package MusicBrainz::Server::Edit::Release::Move;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Change release group' }
sub edit_type { $EDIT_RELEASE_MOVE }

has '+data' => (
    isa => Dict[
        release_id => Int,
        old_release_group_id => Int,
        new_release_group_id => Int
    ]
);

sub alter_edit_pending
{
    my $self = shift;
    return {
        release => [ $self->data->{release_id} ],
    }
}

sub related_entities
{
    my $self = shift;
    return {
        Release => [ $self->data->{release_id} ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { $self->data->{release_id} => [ 'ArtistCredit' ] },
        ReleaseGroup => {
            $self->data->{old_release_group_id} => [ 'ArtistCredit' ],
            $self->data->{new_release_group_id} => [ 'ArtistCredit' ],
        },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        release => $loaded->{Release}->{ $self->data->{release_id} },
        old_group => $loaded->{ReleaseGroup}->{ $self->data->{old_release_group_id} },
        new_group => $loaded->{ReleaseGroup}->{ $self->data->{new_release_group_id} },
    }
}

sub initialize
{
    my ($self, %opts) = @_;

    my $release = $opts{release} or die 'No release object';
    my $release_group_id = $opts{new_release_group_id} or die 'No new release group';

    $self->data({
        release_id => $release->id,
        old_release_group_id => $release->release_group_id,
        new_release_group_id => $release_group_id
    });
}

sub accept
{
    my $self = shift;
    $self->c->model('Release')->update($self->data->{release_id}, {
        release_group_id => $self->data->{new_release_group_id}   
    });
}

1;
