package MusicBrainz::Server::Controller::URL;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Url - Catalyst Controller for working
with Url entities

=cut

=head1 DESCRIPTION

Handles user interaction with URL entities (which are used in advanced
relationships).

=head1 METHODS

=head2 url

Base method for chaining - loads the URL into the stash

=cut

sub url : Chained CaptureArgs(1)
{
    my ($self, $c, $mbid) = @_;
    $c->stash->{url} = $c->model('Url')->load($mbid);
}

# TODO
sub show : Chained('url') PathPart('') { }

=head2 info

Provides information about a given link

=cut

sub info : Chained('url')
{
    my ($self, $c) = @_;
    $c->forward('relations');
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

sub edit : Chained('url') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $url = $c->stash->{url};

    my $form = $self->form;
    $form->init($url);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert;

    $c->response->redirect($c->entity_url($url, 'info'));
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
