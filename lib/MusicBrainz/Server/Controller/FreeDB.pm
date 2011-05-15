package MusicBrainz::Server::Controller::FreeDB;

use Moose;
use TryCatch;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'FreeDB',
    arg_count => 2        # Category/FreeDB ID
};

sub base : Chained('/') PathPart('freedb') CaptureArgs(0) { }

sub _load {
    my ($self, $c, $category, $id) = @_;

    try {
        return $c->model('FreeDB')->lookup($category, $id);
    }
    catch (MusicBrainz::Server::Exceptions::InvalidInput $e) {
        $c->stash( message => $e->message );
        $c->detach('/error_500');
    }
}

sub show : Chained('load') PathPart('') {}

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
