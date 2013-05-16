package MusicBrainz::Server::Controller::Track;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'track',
    model       => 'Track',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';

use MusicBrainz::Server::Entity::Track;

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
    my $track = $c->stash->{track};

    my $release_gid = $c->model('Release')->find_gid_for_track ($track->id);

    my $fragment = '#' . $track->gid;

    $c->response->redirect($c->uri_for_action('/release/show', [ $release_gid ])
                           . $fragment, 303);
    $c->detach;
}


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

