package MusicBrainz::Server::Controller::Tag;
use Moose;
use Moose::Util qw( find_meta );

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Tag',
    entity_name => 'tag'
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

    my $cloud = $c->model('Tag')->get_cloud(200);
    my $hits = scalar @$cloud;

    $c->stash(
        current_view => 'Node',
        component_path => 'tag/TagCloud',
        component_props => {
            %{$c->stash->{component_props}},
            tagMaxCount => $hits ? $cloud->[0]->{count} : 0,
            tags => $hits ? [sort { $a->{tag}->name cmp $b->{tag}->name } @$cloud] : [],
        },
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
            tag => $tag,
            taggedEntities => {
                map {
                    my ($entities, $total) = $c->model(type_to_model($_))->tags->find_entities(
                        $tag->id, 10, 0);
                    $c->model('ArtistCredit')->load(map { $_->entity } @$entities);

                    ("$_" => {
                        count => $total,
                        tags => [map +{
                            count => $_->{count},
                            entity => $_->{entity},
                            entity_id => $_->{entity_id},
                        }, @$entities],
                    })
                } entities_with('tags')
            },
        },

    );
}

map {
    my $entity_type = $_;
    my $entity_properties = $ENTITIES{$entity_type};
    my $url = $entity_properties->{url};

    my $method = sub {
        my ($self, $c) = @_;

        my $entity_tags = $self->_load_paged($c, sub {
            $c->model($entity_properties->{model})->tags->find_entities($c->stash->{tag}->id, shift, shift);
        });

        $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags) if $entity_properties->{artist_credits};
        $c->stash(
            current_view => 'Node',
            component_path => 'tag/EntityList',
            component_props => {
                %{$c->stash->{component_props}},
                entityTags => [map +{
                    count => $_->{count},
                    entity => $_->{entity},
                    entity_id => $_->{entity_id},
                }, @$entity_tags],
                entityType => $entity_type,
                page => "/$url",
                pager => serialize_pager($c->stash->{pager}),
                tag => $c->stash->{tag},
            },
        );
    };

    find_meta(__PACKAGE__)->add_method($_ => $method);
    find_meta(__PACKAGE__)->register_method_attributes($method, ["Chained('load')", "PathPart('$url')"]);
} entities_with('tags');

sub not_found : Private
{
    my ($self, $c, $tagname) = @_;
    $c->response->status(404);
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

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
