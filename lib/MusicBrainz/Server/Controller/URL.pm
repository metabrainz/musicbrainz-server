package MusicBrainz::Server::Controller::URL;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config(
    model => 'URL',
    entity_name => 'url'
);

use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );

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

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'url/index.tt';
}

=head2 relations

List all relations of a url

=cut

sub relations : Chained('url')
{
    my ($self, $c) = @_;
    my $url = $c->stash->{url};

    $c->stash->{relations} = $c->model('Relation')->load_relations($url);
}

=head2 edit

Edit the details of an already existing link

=cut

sub edit : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $url = $c->stash->{url};
    $self->edit_action($c,
        form => 'URL',
        item => $url,
        type => $EDIT_URL_EDIT,
        edit_args => { url_entity => $url },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action('/url/show', [ $url->gid ]));
        }
    );
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
