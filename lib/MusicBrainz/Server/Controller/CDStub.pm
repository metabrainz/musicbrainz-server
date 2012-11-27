package MusicBrainz::Server::Controller::CDStub;
use Moose;
use MusicBrainz::Server::Validation qw( is_valid_discid );
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use aliased 'MusicBrainz::Server::Entity::CDTOC';

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::ControllerUtils::CDTOC qw( add_dash );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'CDStubTOC',
    entity_name => 'cdstubtoc',
};

sub base : Chained('/') PathPart('cdstub') CaptureArgs(0) { }

sub _load 
{
    my ($self, $c, $id) = @_;

    add_dash($c, $id);

    if (!is_valid_discid($id)) {
        $c->stash(
                template  => 'cdstub/error.tt',
                not_valid => 1,
                discid    => $id
                );
        $c->detach;
        return;
    }
    my $cdstubtoc = $c->model('CDStubTOC')->get_by_discid($id);
    if (!$cdstubtoc) {
        $c->stash(
                template  => 'cdstub/error.tt',
                not_found => 1,
                discid    => $id
                );
        $c->detach;
        return;
    }
    $c->model('CDStub')->load($cdstubtoc);
    $c->model('CDStubTrack')->load_for_cdstub($cdstubtoc->cdstub);
    $cdstubtoc->update_track_lengths;

    $c->stash->{show_artists} = !defined($cdstubtoc->cdstub->artist) ||
                                $cdstubtoc->cdstub->artist eq '';
    $c->stash->{cdstub} = $cdstubtoc;
}

sub add : Path('add') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->res->code(403);
        $c->stash( template => 'cdstub/logged_in.tt' );
    }

    my $toc = CDTOC->new_from_toc( $c->req->query_params->{toc} );
    if (!$toc) {
        $c->stash( message => l('The required TOC parameter was invalid or not present') );
        $c->detach('/error_400');
    }

    if(my $cdstub = $c->model('CDStub')->get_by_discid($toc->discid)) {
        $c->response->redirect(
            $c->uri_for_action('/cdstub/show', [ $toc->discid ]));
        $c->detach;
    }

    if(my $cdtoc = $c->model('CDTOC')->get_by_discid($toc->discid)) {
        $c->response->redirect(
            $c->uri_for_action('/cdtoc/show', [ $toc->discid ]));
        $c->detach;
    }

    my $form = $c->form(
        form => 'CDStub',
        init_object => {
            tracks => [ map +{}, (1..$toc->track_count) ]
        }
    );
    $c->stash( template => 'cdstub/add.tt' );
    if ($form->submitted_and_valid($c->req->params)) {
        my $form_val = $form->value;
        $c->model('CDStub')->insert({
            %$form_val,
            toc => $toc->toc,
            discid => $toc->discid
        });

        $c->response->redirect($c->uri_for_action('/cdstub/show', [ $toc->discid ]));
        $c->detach;
    }
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    $c->stash( template => 'cdstub/index.tt' );
}

sub browse : Path('browse')
{
    my ($self, $c) = @_;

    my $stubs = $self->_load_paged($c, sub {
                    $c->model('CDStub')->load_top_cdstubs(shift, shift);
                });
    $c->stash( 
              template => 'cdstub/browse.tt',
              cdstubs  => $stubs
             );
}

sub edit : Chained('load')
{
    my ($self, $c) = @_;
    my $cdstub_toc = $c->stash->{cdstub};
    my $stub = $cdstub_toc->cdstub;

    my $form = $c->form(form => 'CDStub', init_object => $stub);
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('CDStub')->update($stub, $form->value);

        $c->res->redirect(
            $c->uri_for_action($self->action_for('show'), [ $cdstub_toc->discid ])
        );
    }
}

sub import : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $cdstub_toc = $c->stash->{cdstub};
    my $stub = $cdstub_toc->cdstub;

    my $search_query = $stub->artist || 'Various Artists';
    my $form = $c->form(
        form => 'Search::Query',
        item => { query => $search_query }
    );
    if($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $search_query = $form->field('query')->value;
    }

    $c->stash(
        artists => $self->_load_paged($c, sub {
            $c->model('Search')->search('artist', $search_query, shift, shift);
        })
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

1;
