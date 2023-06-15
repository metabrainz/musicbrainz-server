package MusicBrainz::Server::Controller::Track;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Validation qw( is_guid );

BEGIN { extends 'MusicBrainz::Server::Controller'; }
with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'track',
    model       => 'Track',
};

=head1 NAME

MusicBrainz::Server::Controller::Track

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Entity::Track> entities.

=head1 METHODS

=head2 READ ONLY METHODS

=head2 base

Base action to specify that all actions live in the C<track>
namespace

=cut

sub base : Chained('/') PathPart('track') CaptureArgs(0) { }

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $uri;

    if (defined ($c->stash->{recording}))
    {
        $uri = $c->uri_for_action('/recording/show', [ $c->stash->{recording}->gid ]);
        # The track link is now a recording link: this should be considered a permanent move
        $c->response->redirect($uri, 301);
    }
    else
    {
        my $track = $c->stash->{track};
        my $medium = $c->model('Medium')->get_by_id($track->medium_id);
        my $release_gid = $c->model('Release')->find_gid_for_track($track->id);

        $uri = $c->uri_for_action('/release/show', [ $release_gid ]);
        $uri->path($uri->path . '/disc/' . $medium->position);
        $uri->fragment($track->gid);

        $c->response->redirect($uri, 303);
    }

    $c->detach;
}

around load => sub {
    my ($orig, $self, $c, $id) = @_;

    # The /track/:mbid link can be an old link to a pre-ngs track
    # entity, which became recording entities with ngs.  If no
    # recording with the the specified :mbid exists, use the normal
    # load() methods from Role::Load.  If a recording :mbid does
    # exist, stash it so we can redirect to /recording/:mbid in
    # show().

    my $recording;
    if (is_guid($id)) {
        $recording = $c->model('Recording')->get_by_gid($id);
    }
    return $self->$orig($c, $id) unless defined $recording;

    $c->stash( recording => $recording );
    $c->stash( entity    => $recording );
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;

