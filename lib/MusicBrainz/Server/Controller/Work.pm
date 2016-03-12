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
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Work',
    entity_name     => 'work',
    relationships   => { all => ['show'], cardinal => ['edit'], default => ['url'] },
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

    $c->model('ISWC')->load_for_works($work);
};

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    $c->model('Work')->load_writers($c->stash->{work});

    $c->stash->{template} = 'work/index.tt';
}

before qw( show aliases tags details ) => sub {
    my ($self, $c) = @_;
    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
    $c->model('Language')->load_for_works($work);
    $c->model('WorkAttribute')->load_for_works($work);
};

# Stuff that has the side bar and thus needs to display collection information
after [qw( show collections details tags )] => sub {
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

before 'edit' => sub
{
    my ($self, $c) = @_;
    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
    $c->model('WorkAttribute')->load_for_works($work);
    stash_work_attribute_json($c);
};

sub stash_work_attribute_json {
    my ($c) = @_;

    my $build_json;
    my $coll = $c->get_collator();

    $build_json = sub {
        my ($root, $out) = @_;

        $out //= {};

        my @children = map { $build_json->($_, $_->TO_JSON) }
                       $root->sorted_children($coll);
        $out->{children} = [ @children ] if scalar(@children);

        return $out;
    };

    $c->stash(
        workAttributeTypesJson => $c->json->encode(
            $build_json->($c->model('WorkAttributeType')->get_tree)
        ),
        workAttributeValuesJson => $c->json->encode(
            $build_json->($c->model('WorkAttributeTypeAllowedValue')->get_tree)
        )
    );
}

sub _merge_load_entities
{
    my ($self, $c, @works) = @_;
    $c->model('Work')->load_meta(@works);
    $c->model('WorkType')->load(@works);
    if ($c->user_exists) {
        $c->model('Work')->rating->load_user_ratings($c->user->id, @works);
    }
    $c->model('Work')->load_writers(@works);
    $c->model('Work')->load_recording_artists(@works);
    $c->model('WorkAttribute')->load_for_works(@works);
    $c->model('Language')->load_for_works(@works);
    $c->model('ISWC')->load_for_works(@works);
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

before 'create' => sub {
    my ($self, $c) = @_;
    stash_work_attribute_json($c);
};

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky, 2013 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
