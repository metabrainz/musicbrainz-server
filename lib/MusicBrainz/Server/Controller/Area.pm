package MusicBrainz::Server::Controller::Area;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Area',
    relationships   => {
        cardinal    => ['edit'],
        subset      => {
            show => [qw( area artist label place series instrument release_group url )],
            recordings => ['recording'],
            releases => ['release'],
            works => ['work'],
        },
        default     => ['url']
    },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {}, aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'area'
};

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Constants qw( $EDIT_AREA_CREATE $EDIT_AREA_EDIT $EDIT_AREA_DELETE $EDIT_AREA_MERGE );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
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

after 'load' => sub {
    my ($self, $c) = @_;

    my $area = $c->stash->{area};

    $c->model('AreaType')->load($area);
    $c->model('Area')->load_containment($area);
};

=head2 show

Shows an area's main landing page.

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my %props = (
        area              => $c->stash->{area}->TO_JSON,
        numberOfRevisions => $c->stash->{number_of_revisions},
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'area/AreaIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

=head2 artists

Shows artists for an area.

=cut

sub artists : Chained('load')
{
    my ($self, $c) = @_;
    my $artists = $self->_load_paged($c, sub {
        $c->model('Artist')->find_by_area($c->stash->{area}->id, shift, shift);
    });
        $c->model('ArtistType')->load(@$artists);
        $c->model('Gender')->load(@$artists);
        $c->model('Area')->load(@$artists);
        $c->model('Area')->load_containment(map { $_->{area}, $_->{begin_area}, $_->{end_area} } @$artists);
        $c->model('Artist')->load_meta(@$artists);
    if ($c->user_exists) {
        $c->model('Artist')->rating->load_user_ratings($c->user->id, @$artists);
    }

    my %props = (
        area        => $c->stash->{area}->TO_JSON,
        artists     => to_json_array($artists),
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaArtists',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 events

Shows all events for an area.

=cut

sub events : Chained('load')
{
    my ($self, $c) = @_;
    my $events = $self->_load_paged($c, sub {
        $c->model('Event')->find_by_area($c->stash->{area}->id, shift, shift);
    });
    $c->model('Event')->load_related_info(@$events);
    $c->model('Area')->load(map { $_->{entity} } map { $_->all_places } @$events);
    $c->model('Area')->load_containment(map { (map { $_->{entity} } $_->all_areas),
                                              (map { $_->{entity}->area } $_->all_places) } @$events);
    $c->model('Event')->load_meta(@$events);
    $c->model('Event')->rating->load_user_ratings($c->user->id, @$events) if $c->user_exists;

    my %props = (
        area       => $c->stash->{area}->TO_JSON,
        events      => to_json_array($events),
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaEvents',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 labels

Shows labels for an area.

=cut

sub labels : Chained('load')
{
    my ($self, $c) = @_;
    my $labels = $self->_load_paged($c, sub {
        $c->model('Label')->find_by_area($c->stash->{area}->id, shift, shift);
    });
    $c->model('LabelType')->load(@$labels);
    $c->model('Area')->load(@$labels);
    $c->model('Area')->load_containment(map { $_->{area} } @$labels);
    $c->model('Label')->load_meta(@$labels);
    if ($c->user_exists) {
        $c->model('Label')->rating->load_user_ratings($c->user->id, @$labels);
    }

    my %props = (
        area         => $c->stash->{area}->TO_JSON,
        labels       => to_json_array($labels),
        pager        => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaLabels',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 releases

Shows releases for an area

=cut

sub releases : Chained('load')
{
    my  ($self, $c) = @_;

    my $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_country($c->stash->{area}->id, shift, shift);
        });

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Release')->load_related_info(@$releases);

    my %props = (
        area        => $c->stash->{area}->TO_JSON,
        releases    => to_json_array($releases),
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaReleases',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 places

Shows places for an area.

=cut

sub places : Chained('load')
{
    my ($self, $c) = @_;
    my $places = $self->_load_paged($c, sub {
        $c->model('Place')->find_by_area($c->stash->{area}->id, shift, shift);
    });
    $c->model('PlaceType')->load(@$places);
    $c->model('Area')->load(@$places);
    $c->model('Area')->load_containment(map { $_->area } @$places);

    my %props = (
        area        => $c->stash->{area}->TO_JSON,
        mapDataArgs => $c->json->encode({
            places => [
                map {
                    my $json = $_->TO_JSON;
                    # These arguments aren't needed at all to render the map,
                    # and only increase the page size.
                    delete @{$json}{qw(annotation unaccented_name)};
                    $json;
                } grep { $_->coordinates } @$places
            ],
        }),
        places      => to_json_array($places),
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaPlaces',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 users

Shows editors located in this area.

=cut

sub users : Chained('load') {
    my ($self, $c) = @_;
    my $editors = $self->_load_paged($c, sub {
        my ($editors, $total) = $c->model('Editor')->find_by_area($c->stash->{area}->id, shift, shift);
        $c->model('Editor')->load_preferences(@$editors);
        ($editors, $total);
    });

    my %props = (
        area        => $c->stash->{area}->TO_JSON,
        editors     => to_json_array($editors),
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'area/AreaUsers',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 recordings

Shows recordings related to this area.

=cut

sub recordings : Chained('load') {
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'area/AreaRecordings',
        component_props => { area => $c->stash->{area}->TO_JSON },
        current_view => 'Node',
    );
}

=head2 works

Shows works related to this area.

=cut

sub works : Chained('load') {
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'area/AreaWorks',
        component_props => { area => $c->stash->{area}->TO_JSON },
        current_view => 'Node',
    );
}

after [qw( show collections details tags aliases artists labels releases recordings places users works )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

=head2 WRITE METHODS

=cut

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Area',
    edit_type => $EDIT_AREA_CREATE,
    dialog_template => 'area/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Area',
    edit_type      => $EDIT_AREA_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_AREA_MERGE,
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_AREA_DELETE,
};

for my $method (qw( create edit merge merge_queue delete add_alias edit_alias delete_alias edit_annotation )) {
    before $method => sub {
        my ($self, $c) = @_;
        if (!$c->user->is_location_editor) {
            $c->detach('/error_403');
        }
    };
};

before qw( create edit ) => sub {
    my ($self, $c) = @_;
    my %area_types = map {$_->id => $_} $c->model('AreaType')->get_all();
    $c->stash->{area_types} = \%area_types;
};

sub _merge_load_entities
{
    my ($self, $c, @areas) = @_;
    $c->model('Area')->load_containment(@areas);
    $c->model('AreaType')->load(@areas);
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
