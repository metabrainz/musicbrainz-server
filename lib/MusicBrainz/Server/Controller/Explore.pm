package MusicBrainz::Server::Controller::Explore;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::Util qw( min max );
use MusicBrainz::Server::Data::Utils qw( model_to_type type_to_model );
use Scalar::Util qw( looks_like_number );
use feature 'switch';

no if $] >= 5.018, warnings => "experimental::smartmatch";

sub explore : Path('')
{
    my ($self, $c) = @_;

    # Backwards compatibility with existing URLs
    $c->req->query_params->{method} = 'direct'
        if ($c->req->query_params->{direct} // '') eq 'on';

    $c->req->query_params->{type} = 'recording'
        if exists $c->req->query_params->{type} && $c->req->query_params->{type} eq 'track';

        $c->stash( template => 'explore/index.tt' );
}

sub doc : Private
{
    my ($self, $c) = @_;

    $c->stash(
      google_custom_explore => DBDefs->GOOGLE_CUSTOM_SEARCH,
      template             => 'explore/results-doc.tt'
    );
}


sub direct : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    my $type   = $form->field('type')->value;
    my $query  = $form->field('query')->value;

    my $results = $self->_load_paged($c, sub {
       $c->model('Explore')->explore($type, $query, shift, shift);
    }, limit => $form->field('limit')->value);

    my @entities = map { $_->entity } @$results;

    given ($type) {
        when ('artist') {
            $c->model('ArtistType')->load(@entities);
            $c->model('Area')->load(@entities);
            $c->model('Gender')->load(@entities);
        }
        when ('editor') {
            $c->model('Editor')->load_preferences(@entities);
        }
        when ('release_group') {
            $c->model('ReleaseGroupType')->load(@entities);
        }
        when ('release') {
            $c->model('Language')->load(@entities);
            $c->model('Release')->load_release_events(@entities);
            $c->model('Script')->load(@entities);
            $c->model('Medium')->load_for_releases(@entities);
            $c->model('MediumFormat')->load(map { $_->all_mediums } @entities);
            $c->model('ReleaseStatus')->load(@entities);
            $c->model('ReleaseLabel')->load(@entities);
            $c->model('Label')->load(map { $_->all_labels} @entities);
            $c->model('ReleaseGroup')->load(@entities);
            $c->model('ReleaseGroupType')->load(map { $_->release_group }
                @entities);
        }
        when ('label') {
            $c->model('LabelType')->load(@entities);
            $c->model('Area')->load(@entities);
        }
        when ('recording') {
            my %recording_releases_map = $c->model('Release')->find_by_recordings(map {
                $_->entity->id
            } @$results);
            my %result_map = map { $_->entity->id => $_ } @$results;

            $result_map{$_}->extra(
                [ map { $_->[0] } @{ $recording_releases_map{$_} } ]
            ) for keys %recording_releases_map;

            my @releases = map { @{ $_->extra } } @$results;
            $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
            $c->model('Medium')->load_for_releases(@releases);
            $c->model('Track')->load_for_mediums(map { $_->all_mediums } @releases);
            $c->model('Recording')->load(
                map { $_->all_tracks } map { $_->all_mediums } @releases);
            $c->model('ISRC')->load_for_recordings(map { $_->entity } @$results);
        }
        when ('work') {
            $c->model('Work')->load_writers(@entities);
            $c->model('Work')->load_recording_artists(@entities);
            $c->model('ISWC')->load_for_works(@entities);
            $c->model('Language')->load(@entities);
            $c->model('WorkType')->load(@entities);
        }
        when ('area') {
            $c->model('AreaType')->load(@entities);
            $c->model('Area')->load_containment(@entities);
        }
        when ('place') {
            $c->model('PlaceType')->load(@entities);
            $c->model('Area')->load(@entities);
        }
        when ('instrument') {
            $c->model('InstrumentType')->load(@entities);
        }
        when ('series') {
            $c->model('SeriesType')->load(@entities);
            $c->model('SeriesOrderingType')->load(@entities);
        }
        when ('event') {
            $c->model('Event')->load_related_info(@entities);
            $c->model('Event')->load_areas(@entities);
        }
    }

    if ($type =~ /(recording|release|release_group)/)
    {
        $c->model('ArtistCredit')->load(@entities);
    }

    $c->stash(
        template => sprintf('explore/results-%s.tt', $type),
        query    => $query,
        results  => $results,
        type     => $type,
    );
}


1;

=head1 NAME

MusicBrainz::Server::Controller::Explore - Handles exploring the database.

=head1 DESCRIPTION

This control handles exploring the database for various data, such as
artists and releases by specifying the category to be searched, through a
web interface not necessarily using any queries.

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
