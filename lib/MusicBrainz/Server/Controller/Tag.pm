package MusicBrainz::Server::Controller::Tag;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Tag',
    entity_name => 'tag'
};

sub base : Chained('/') PathPart('tag') CaptureArgs(0) { }

sub _load
{
    my ($self, $c, $name) = @_;
    return $c->model('Tag')->get_by_name($name);
}

sub cloud : Path('/tags')
{
    my ($self, $c, $name) = @_;

    my ($cloud, $hits) = $c->model('Tag')->get_cloud(200);

    if ($hits)
    {
        $c->stash(
            tag_max_count => $cloud->[0]->{count},
            tags => [ sort { $a->{tag}->name cmp $b->{tag}->name } @$cloud ],
        );
    }
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $tag = $c->stash->{tag};
    $c->stash(
        template => 'tag/index.tt',
        map {
            my ($entities, $total) = $c->model(type_to_model($_))->tags->find_entities(
                $tag->id, 10, 0);

            ($_ . '_tags' => $entities,
             $_ . '_count' => $total)
        } qw( artist label recording release release_group work )
    );
}

sub artist : Chained('load')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('Artist')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->stash( entity_tags => $entity_tags );
}

sub label : Chained('load')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('Label')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->stash( entity_tags => $entity_tags );
}

sub recording : Chained('load')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('Recording')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags);
    $c->stash( entity_tags => $entity_tags );
}

sub release : Chained('load') PathPart('release')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('Release')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags);
    $c->stash( entity_tags => $entity_tags );
}

sub release_group : Chained('load') PathPart('release-group')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('ReleaseGroup')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags);
    $c->stash( entity_tags => $entity_tags );
}

sub work : Chained('load')
{
    my ($self, $c) = @_;

    my $entity_tags = $self->_load_paged($c, sub {
        $c->model('Work')->tags->find_entities($c->stash->{tag}->id, shift, shift);
    });
    $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags);
    $c->stash( entity_tags => $entity_tags );
}

sub not_found
{
    my ($self, $c, $tagname) = @_;
    $c->response->status(404);
    $c->stash( template => 'tag/not_found.tt',
               tag => $tagname );
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
