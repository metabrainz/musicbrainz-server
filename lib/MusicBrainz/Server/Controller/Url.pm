package MusicBrainz::Server::Controller::Url;

use strict;
use warnings;

use base 'Catalyst::Controller';

use Carp;
use MusicBrainz::Server::Adapter qw(LoadEntity);
use MusicBrainz::Server::Adapter::Relations qw(LoadRelations);
use MusicBrainz::Server::URL;
use MusicBrainz;

=head1 NAME

MusicBrainz::Server::Controller::Url - Catalyst Controller for working
with Url entities

=cut

=head1 DESCRIPTION

Handles user interaction with URL entities (which are used in advanced
relationships).

=head1 METHODS

=head2 info

Provides information about a given link

=cut

sub info : Path Args(1)
{
    my ($self, $c, $mbid) = @_;

    # Load the URL
    my $url = MusicBrainz::Server::URL->new($c->mb->{DBH});
    MusicBrainz::Server::Adapter::LoadEntity($url, $mbid);

    # Store in the stash
    $c->stash->{url}       = $url->ExportStash qw( description );
    $c->stash->{relations} = MusicBrainz::Server::Adapter::Relations::LoadRelations($url, 'url');

    $c->stash->{template} = 'url/info.tt';
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

1
