package MusicBrainz::Server::Controller::Tag;
use Moose;
use Moose::Util qw( find_meta );
use MooseX::MethodAttributes;
use HTTP::Status qw( :constants );

extends 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Tag',
    entity_name => 'tag',
};

sub base : Chained('/') PathPart('tag') CaptureArgs(0) { }

sub _load
{
    my ($self, $c, $name) = @_;
    my $tag = $c->model('Tag')->get_by_name($name);
    if ($tag && $tag->genre_id) {
        $c->model('Genre')->load($tag);
    }
    return $tag;
}

sub no_tag_provided : Path('/tag') Args(0)
{
    my ($self, $c, $name) = @_;

    # If no tag is passed, redirect to the tag cloud
    $c->response->redirect(
        $c->uri_for_action('/tag/cloud'));
    $c->detach;
}

sub cloud : Path('/tags')
{
    my ($self, $c, $name) = @_;

    my $show_list = $c->req->params->{show_list} ? 1 : 0;

    my $cloud = $c->model('Tag')->get_cloud();
    my $genres = $cloud->{genres};
    my $genre_hits = scalar @$genres;
    my $tags = $cloud->{other_tags};
    my $tag_hits = scalar @$tags;

    $c->stash(
        current_view => 'Node',
        component_path => 'tag/TagCloud',
        component_props => {
            %{$c->stash->{component_props}},
            genreMaxCount => $genre_hits ? $genres->[0]->{count} + 0 : 0,
            genres => $genre_hits ? [
                map +{
                    count => $_->{count} + 0,
                    tag => to_json_object($_->{tag}),
                },
                sort { $a->{tag}->name cmp $b->{tag}->name }
                @$genres,
            ] : [],
            showList => boolean_to_json($show_list),
            tagMaxCount => $tag_hits ? $tags->[0]->{count} + 0 : 0,
            tags => $tag_hits ? [
                map +{
                    count => $_->{count} + 0,
                    tag => to_json_object($_->{tag}),
                },
                sort { $a->{tag}->name cmp $b->{tag}->name }
                @$tags,
            ] : [],
        },
    );
}

sub delete : Chained('load') RequireAuth{
    my ($self, $c) = @_;

    my $tag = $c->stash->{tag};
    my $delete_downvoted = $c->req->params->{delete_downvoted} ? 1 : 0;

    if ($c->form_posted) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Tag')->delete_for_user($tag->id, $c->user->id, $delete_downvoted);
        });

        $c->response->redirect($c->uri_for_action('user/tags',
                                                  [ $c->user->name ],
                                                  { show_downvoted => $delete_downvoted }));
    }

    my %props = (
        deleteDownvoted => boolean_to_json($delete_downvoted),
        tag => $tag->TO_JSON,
    );

    $c->stash(
        component_path => 'tag/DeleteTag',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $tag = $c->stash->{tag};
    $c->stash(
        current_view => 'Node',
        component_path => 'tag/TagIndex',
        component_props => {
            %{$c->stash->{component_props}},
            tag => $tag->TO_JSON,
            taggedEntities => {
                map {
                    my $entity_properties = $ENTITIES{$_};
                    my $model = $c->model($entity_properties->{model});

                    my ($entity_tags, $total) = $model->tags->find_entities(
                        $tag->id, 10, 0);

                    my @entities = map { $_->entity } @$entity_tags;
                    $model->load_aliases(@entities)
                        if $entity_properties->{aliases};
                    $c->model('ArtistCredit')->load(@entities)
                        if $entity_properties->{artist_credits};

                    ("$_" => {
                        count => $total,
                        tags => [map +{
                            count => $_->{count},
                            entity => $_->{entity}->TO_JSON,
                            entity_id => $_->{entity_id},
                        }, @$entity_tags],
                    })
                } entities_with('tags'),
            },
        },

    );
}

for my $entity_type (entities_with('tags')) {
    my $entity_properties = $ENTITIES{$entity_type};
    my $url = $entity_properties->{url};

    my $method = sub {
        my ($self, $c) = @_;

        my $model = $c->model($entity_properties->{model});
        my $entity_tags = $self->_load_paged($c, sub {
            $model->tags->find_entities($c->stash->{tag}->id, shift, shift);
        });
        my @entities = map { $_->entity } @$entity_tags;

        $model->load_aliases(@entities) if $model->can('load_aliases');
        $c->model('ArtistCredit')->load(@entities) if $entity_properties->{artist_credits};
        $c->stash(
            current_view => 'Node',
            component_path => 'tag/EntityList',
            component_props => {
                %{$c->stash->{component_props}},
                entityTags => [map +{
                    count => $_->{count},
                    entity => $_->{entity}->TO_JSON,
                    entity_id => $_->{entity_id},
                }, @$entity_tags],
                entityType => $entity_type,
                page => "/$url",
                pager => serialize_pager($c->stash->{pager}),
                tag => $c->stash->{tag}->TO_JSON,
            },
        );
    };

    find_meta(__PACKAGE__)->add_method($entity_type => $method);
    find_meta(__PACKAGE__)->register_method_attributes($method, [q{Chained('load')}, "PathPart('$url')"]);
}

sub not_found : Private
{
    my ($self, $c, $tagname) = @_;
    $c->response->status(HTTP_NOT_FOUND);
    $c->stash(
        current_view => 'Node',
        component_path => 'tag/NotFound',
        component_props => {
            %{$c->stash->{component_props}},
            tag => $tagname,
        },
    );
    $c->detach;
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
