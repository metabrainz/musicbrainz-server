package MusicBrainz::Server::Controller::Work;
use 5.10.0;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_CREATE
    $EDIT_WORK_EDIT
    $EDIT_WORK_MERGE
    $EDIT_WORK_ADD_ISWCS
    $EDIT_WORK_REMOVE_ISWC
);
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Form::Utils qw(
    build_grouped_options
    build_json
    language_options
);
use MusicBrainz::Server::Translation qw( l );
use List::AllUtils qw( any );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Work',
    entity_name     => 'work',
    relationships   => {
        cardinal => ['edit'],
        default => ['url'],
        subset => {
            show => [qw( area artist label place release release_group
                         url work series instrument )],
        },
        paged_subset => {
            show => [qw( recording )],
        },
    },
};
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {}, aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'work'
};

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';

sub base : Chained('/') PathPart('work') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    my $returning_jsonld = $self->should_return_jsonld($c);

    unless ($returning_jsonld) {
        $c->model('Work')->load_meta($work);

        if ($c->user_exists) {
            $c->model('Work')->rating->load_user_ratings($c->user->id, $work);
        }
    }

    $c->model('WorkType')->load($work);
    $c->model('ISWC')->load_for_works($work);
};

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $stash = $c->stash;
    $c->model('Work')->load_writers($stash->{work});

    my $pager = defined $stash->{pager}
        ? serialize_pager($stash->{pager})
        : undef;

    my %props = (
        numberOfRevisions => $stash->{number_of_revisions},
        pagedLinkTypeGroup => to_json_object($stash->{paged_link_type_group}),
        pager => $pager,
        wikipediaExtract => to_json_object($stash->{wikipedia_extract}),
        work => $stash->{work}->TO_JSON,
    );

    $c->stash(
        component_path => 'work/WorkIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

# Stuff that has the side bar and thus needs to display collection information
after [qw( show collections details tags aliases )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

with 'MusicBrainz::Server::Controller::Role::IdentifierSet' => {
    entity_type => 'work',
    identifier_type => 'iswc',
    add_edit => $EDIT_WORK_ADD_ISWCS,
    remove_edit => $EDIT_WORK_REMOVE_ISWC
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Work',
    edit_type      => $EDIT_WORK_EDIT,
    edit_arguments => sub {
        my ($self, $c, $work) = @_;

        return (
            post_creation => $self->edit_with_identifiers($c, $work),
            edit_args => {
                to_edit => $work,
            }
        );
    }
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_WORK_MERGE,
};

before qw( show aliases tags details edit ) => sub {
    my ($self, $c) = @_;
    my $work = $c->stash->{work};
    $c->model('Language')->load_for_works($work);
    $c->model('WorkAttribute')->load_for_works($work);
};

after edit => sub {
    my ($self, $c) = @_;

    stash_work_form_json($c);
};

sub stash_work_form_json {
    my ($c) = @_;

    my $json = {};
    $json->{form} = $c->stash->{form}->TO_JSON;

    my $work = $c->stash->{work};
    $json->{work} = $work ? $work->TO_JSON : {name => ''};

    $json->{workAttributeTypeTree} =
        build_json($c, $c->model('WorkAttributeType')->get_tree);

    $json->{workAttributeValueTree} =
        build_json($c, $c->model('WorkAttributeTypeAllowedValue')->get_tree);

    $json->{workLanguageOptions} =
        build_grouped_options($c, language_options($c, 'work'));

    $c->stash(work_form_json => $json);
}

sub _merge_load_entities
{
    my ($self, $c, @works) = @_;
    $c->model('Work')->load_meta(@works);
    $c->model('WorkType')->load(@works);
    $c->model('Work')->load_writers(@works);
    $c->model('Work')->load_recording_artists(@works);
    $c->model('WorkAttribute')->load_for_works(@works);
    $c->model('Language')->load_for_works(@works);
    $c->model('ISWC')->load_for_works(@works);

    my @works_with_iswcs = grep { $_->all_iswcs > 0 } @works;
    if (@works_with_iswcs > 1) {
        my ($comparator, @tail) = @works_with_iswcs;
        my $get_iswc_set = sub { Set::Scalar->new(map { $_->iswc } shift->all_iswcs) };
        my $expect = $get_iswc_set->($comparator);
        $c->stash(
            iswcs_differ => (any { $get_iswc_set->($_) != $expect } @tail),
        );
    }
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Work',
    edit_type => $EDIT_WORK_CREATE,
    edit_arguments => sub {
        my ($self, $c) = @_;

        return (
            post_creation => $self->create_with_identifiers($c)
        );
    },
    dialog_template => 'work/edit_form.tt',
};

after create => sub {
    my ($self, $c) = @_;

    stash_work_form_json($c);
};

before qw( create edit ) => sub {
    my ($self, $c) = @_;
    my %work_types = map {$_->id => $_} $c->model('WorkType')->get_all();
    $c->stash->{work_types} = \%work_types;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky, 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

