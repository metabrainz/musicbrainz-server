package MusicBrainz::Server::Controller::URL;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'URL',
    entity_name     => 'url',
    relationships   => { all => ['show', 'edit'] }
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';

=head1 NAME

MusicBrainz::Server::Controller::Url - Catalyst Controller for working
with Url entities

=cut

=head1 DESCRIPTION

Handles user interaction with URL entities (which are used in advanced
relationships).

=head1 METHODS

=cut

sub base : Chained('/') PathPart('url') CaptureArgs(0) { }

sub show : Chained('load') PathPart('') {
    my ($self, $c) = @_;
    $c->stash(
        component_path => 'url/UrlIndex',
        component_props => {url => $c->stash->{url}->TO_JSON},
        current_view => 'Node',
    );
}

=head2 edit

Edit the details of an already existing link

=cut

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form      => 'URL',
    edit_type => $EDIT_URL_EDIT,
};

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
