package MusicBrainz::Server::Controller::Tag;
use Moose;
use Moose::Util qw( find_meta );

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );

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
            $c->model('ArtistCredit')->load(map { $_->entity } @$entities);

            ($_ . '_tags' => $entities,
             $_ . '_count' => $total)
        } entities_with('tags')
    );
}

map {
    my $entity_properties = $ENTITIES{$_};
    my $url = $entity_properties->{url} // $_;

    my $method = sub {
        my ($self, $c) = @_;

        my $entity_tags = $self->_load_paged($c, sub {
            $c->model($entity_properties->{model})->tags->find_entities($c->stash->{tag}->id, shift, shift);
        });

        $c->model('ArtistCredit')->load(map { $_->entity } @$entity_tags) if $entity_properties->{artist_credits};
        $c->stash(entity_tags => $entity_tags);
    };

    find_meta(__PACKAGE__)->add_method($_ => $method);
    find_meta(__PACKAGE__)->register_method_attributes($method, ["Chained('load')", "PathPart('$url')"]);
} entities_with('tags');

sub not_found : Private
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
