package MusicBrainz::Server::Controller::Area;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Area',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Translation qw( l );
use Sql;

=head1 NAME

MusicBrainz::Server::Controller::Area - Catalyst Controller for working
with Area entities

=head1 DESCRIPTION

The area controller is used for interacting with
L<MusicBrainz::Server::Area> entities - both read and write. It provides
views to the area data itself, and a means to navigate to a release
that is attributed to a certain area.

=head1 ACTIONS

=head2 READ ONLY PAGES

The follow pages can are all read only.

=head2 base

Base action to specify that all actions live in the C<area>
namespace

=cut

sub base : Chained('/') PathPart('area') CaptureArgs(0) { }

=head2 area

Extends loading by fetching any extra data required in the area header.

=cut

after 'load' => sub
{
    my ($self, $c) = @_;

    my $area = $c->stash->{area};

    $c->model('Area')->load_codes($area);
    $c->model('AreaType')->load($area);
};

=head2 show

Shows an area's main landing page.

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    $c->stash(template => 'area/index.tt');
}

=head1 LICENSE

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
