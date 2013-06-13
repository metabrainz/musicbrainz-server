package MusicBrainz::Server::Controller::Track;
use Moose;
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
    }
    else
    {
        my $track = $c->stash->{track};
        my $release_gid = $c->model('Release')->find_gid_for_track ($track->id);

        $uri = $c->uri_for_action('/release/show', [ $release_gid ]);
        $uri->fragment ($track->gid);
    }

    $c->response->redirect($uri, 303);
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

    my $recording = $c->model('Recording')->get_by_gid($id) if is_guid($id);
    return $self->$orig ($c, $id) unless defined $recording;

    $c->stash( recording => $recording );
    $c->stash( entity    => $recording );
};

=head1 LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;

