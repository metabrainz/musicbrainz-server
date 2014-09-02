package MusicBrainz::Server::Controller::Role::CommonsImage;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use List::UtilsBy qw( sort_by );
use namespace::autoclean;

after url_relationships_loaded => sub {
    my ($self, $c) = @_;

    $self->_get_commons_image($c, 1);
};

sub commons_image : Chained('load') PathPart('commons-image')
{
    my ($self, $c) = @_;

    $self->_get_commons_image($c, 0);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->stash->{template} = 'components/commons-image.tt';
}

sub _get_commons_image
{
    my ($self, $c, $cache_only) = @_;

    my $entity = $c->stash->{entity};
    my ($commons_link) = map {
            $_->target;
        } grep {
            $_->target->isa('MusicBrainz::Server::Entity::URL::Commons')
        } @{ $entity->relationships_by_link_type_names('image') };

    if ($commons_link) {
        my $page_name = $commons_link->page_name;
        my $commons_image = $c->model('CommonsImage')->get_commons_image($page_name, cache_only => $cache_only);
        if ($commons_image) {
            $c->stash->{image} = $commons_image;
        } else {
            $c->stash->{image_url} = $c->uri_for_action($self->action_for('commons_image'), [ $entity->gid ]);
        }
    }
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
