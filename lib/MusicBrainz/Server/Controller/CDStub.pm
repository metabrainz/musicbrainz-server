package MusicBrainz::Server::Controller::CDStub;
use Moose;
use MusicBrainz::Server::Validation qw( is_valid_discid );
BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'CDStubTOC',
    entity_name => 'cdstubtoc',
};

sub base : Chained('/') PathPart('cdstub') CaptureArgs(0) { }

sub _load 
{
    my ($self, $c, $id) = @_;

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

    my $index = 0;
    my @offsets = @{$cdstubtoc->track_offset};
    push @offsets, $cdstubtoc->leadout_offset;
    foreach my $track (@{$cdstubtoc->cdstub->tracks}) {
        $track->length(int((($offsets[$index + 1] - $offsets[$index]) / 75) * 1000));
        $index++;
    }

    $c->stash->{show_artists} = $cdstubtoc->cdstub->artist eq '';
    $c->stash->{cdstub} = $cdstubtoc;
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
