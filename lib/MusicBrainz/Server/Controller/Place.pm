package MusicBrainz::Server::Controller::Place;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Place',
    relationships   => {
        cardinal    => ['edit'],
        default     => ['url'],
        subset      => {
            show => [qw( area artist label place url work series instrument )],
            performances => [qw( release release_group recording work url )],
        }
    },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {}, aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'place'
};

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Constants qw( $EDIT_PLACE_CREATE $EDIT_PLACE_EDIT $EDIT_PLACE_MERGE );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
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

after 'load' => sub {
    my ($self, $c) = @_;

    my $place = $c->stash->{place};
    my $returning_jsonld = $self->should_return_jsonld($c);

    unless ($returning_jsonld) {
        $c->model('Place')->load_meta($place);

        if ($c->user_exists) {
            $c->model('Place')->rating->load_user_ratings($c->user->id, $place);
        }
    }

    $c->model('PlaceType')->load($place);
    $c->model('Area')->load($place);
    $c->model('Area')->load_containment($place->area);
};

=head2 show

Shows a place's main landing page.

=cut

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    my %props = (
        numberOfRevisions => $c->stash->{number_of_revisions},
        place             => $c->stash->{place}->TO_JSON,
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'place/PlaceIndex.js',
        component_props => \%props,
        current_view => 'Node',
    );
}

=head2 events

Shows all events of a place.

=cut

sub events : Chained('load')
{
    my ($self, $c) = @_;
    my $events = $self->_load_paged($c, sub {
        $c->model('Event')->find_by_place($c->stash->{place}->id, shift, shift);
    });
    $c->model('Event')->load_related_info(@$events);
    $c->model('Event')->load_meta(@$events);
    $c->model('Event')->rating->load_user_ratings($c->user->id, @$events) if $c->user_exists;

    my %props = (
        events      => to_json_array($events),
        place       => $c->stash->{place}->TO_JSON,
        pager       => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'place/PlaceEvents.js',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 performances

Shows performances linked to a place.

=cut

sub performances : Chained('load') { 
    my ($self, $c) = @_;

    $c->stash(
        component_path  => 'place/PlacePerformances',
        component_props => {place => $c->stash->{place}->TO_JSON},
        current_view    => 'Node',
    );
}

=head2 map

Shows a map for a place.

=cut

sub map : Chained('load') {
    my ($self, $c) = @_;

    my $place = $c->stash->{place};
    my $map_data_args = $c->json->encode({
        draggable => \0,
        place => {
            coordinates => to_json_object($place->coordinates),
            name => $place->name,
        },
    });

    my %props = (
        mapDataArgs => $map_data_args,
        place       => $place->TO_JSON,
    );

    $c->stash(
        component_path  => 'place/PlaceMap',
        component_props => \%props,
        current_view    => 'Node',
    );

}

after [qw( show collections details tags ratings aliases events performances map )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

=head2 WRITE METHODS

=cut

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Place',
    edit_type => $EDIT_PLACE_CREATE,
    dialog_template => 'place/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Place',
    edit_type      => $EDIT_PLACE_EDIT,
};

after edit => sub {
    my ($self, $c) = @_;

    my $place = $c->stash->{place};
    $c->stash->{map_data_args} = $c->json->encode({
        draggable => \1,
        place => {
            coordinates => $place->coordinates,
            name => $place->name,
        },
        title => '',
    });
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_PLACE_MERGE,
};

before qw( create edit ) => sub {
    my ($self, $c) = @_;
    my %place_types = map {$_->id => $_} $c->model('PlaceType')->get_all();
    $c->stash->{place_types} = \%place_types;
};

sub _merge_load_entities
{
    my ($self, $c, @places) = @_;
    $c->model('PlaceType')->load(@places);
    $c->model('Area')->load(@places);
    $c->model('Area')->load_containment(map { $_->area } @places);
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
