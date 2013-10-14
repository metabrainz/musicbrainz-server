package MusicBrainz::Server::Controller::Place;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Place',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Constants qw( $EDIT_PLACE_CREATE $EDIT_PLACE_EDIT $EDIT_PLACE_MERGE );
use Sql;

=head1 NAME

MusicBrainz::Server::Controller::Place - Catalyst Controller for working
with Place entities

=head1 DESCRIPTION

The place controller is used for interacting with
L<MusicBrainz::Server::Place> entities - both read and write.

=head1 ACTIONS

=head2 READ ONLY PAGES

The follow pages can are all read only.

=head2 base

Base action to specify that all actions live in the C<place>
namespace

=cut

sub base : Chained('/') PathPart('place') CaptureArgs(0) { }

=head2 place

Extends loading by fetching any extra data required in the place header.

=cut

after 'load' => sub
{
    my ($self, $c) = @_;

    my $place = $c->stash->{place};

    $c->model('PlaceType')->load($place);
    $c->model('Area')->load($c->stash->{place});
    $c->model('Area')->load_codes($place->area);
};

=head2 show

Shows a place's main landing page.

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    # need to call relationships for overview page
    $self->relationships($c);

    $c->stash(template => 'place/index.tt');
}

=head2 performances

Shows performances linked to a place.

=cut

sub performances : Chained('load')
{
    my ($self, $c) = @_;

    $self->relationships($c);
}
=head2 WRITE METHODS

=cut

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Place',
    edit_type => $EDIT_PLACE_CREATE,
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Place',
    edit_type      => $EDIT_PLACE_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_PLACE_MERGE,
    confirmation_template => 'place/merge_confirm.tt',
    search_template       => 'place/merge_search.tt',
};

after 'merge' => sub
{
    my ($self, $c) = @_;
    $c->model('PlaceType')->load(@{ $c->stash->{to_merge} });
    $c->model('Area')->load(@{ $c->stash->{to_merge} });
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

1;
