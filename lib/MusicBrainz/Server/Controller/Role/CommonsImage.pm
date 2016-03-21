package MusicBrainz::Server::Controller::Role::CommonsImage;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use List::UtilsBy qw( sort_by );
use namespace::autoclean;
use Readonly;

requires 'load';

Readonly my $WIKIDATA_PROP_IMAGE => "P18";
Readonly my $WIKIDATA_PROP_LOGO_IMAGE => "P154";
Readonly my $WIKIDATA_PROP_LOCATOR_MAP_IMAGE => "P242";

after load => sub {
    my ($self, $c) = @_;

    $self->_get_commons_image($c, 1);
};

sub commons_image : Chained('load') PathPart('commons-image') {
    my ($self, $c) = @_;

    $self->_get_commons_image($c, 0);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->stash->{template} = 'components/commons-image.tt';
}

sub _get_commons_image {
    my ($self, $c, $cache_only) = @_;

    my $entity = $c->stash->{entity};
    my $title;

    # Check if there's a Wikimedia Commons relationship
    my ($commons_link) = map {
            $_->target;
        } grep {
            $_->target->isa('MusicBrainz::Server::Entity::URL::Commons')
        } @{ $entity->relationships_by_link_type_names('image') };
    if ($commons_link) {
        $title = $commons_link->page_name;
    }

    # and if not, check Wikidata entity
    $title = _get_wikidata_image($c) if !$title;

    my $commons_image = $c->model('CommonsImage')->get_commons_image($title, cache_only => $cache_only);
    if ($commons_image) {
        $c->stash->{image} = $commons_image;
    } else {
        $c->stash->{image_url} = $c->uri_for_action($self->action_for('commons_image'), [ $entity->gid ]);
    }
}

sub _get_wikidata_image {
    my ($c) = @_;
    my $entity = $c->stash->{entity};

    my ($wikidata_link) = map {
            $_->target;
        } grep {
            $_->target->isa('MusicBrainz::Server::Entity::URL::Wikidata')
        } @{ $entity->relationships_by_link_type_names('wikidata') };

    if ($wikidata_link) {
        my $properties = $c->model('WikidataProperties')->get_wikidata_properties($wikidata_link->pretty_name);
        if ($entity->isa('MusicBrainz::Server::Entity::Area') &&
            exists $properties->{$WIKIDATA_PROP_LOCATOR_MAP_IMAGE}) {
            return "File:$properties->{$WIKIDATA_PROP_LOCATOR_MAP_IMAGE}[0]{mainsnak}{datavalue}{value}";
        }
        if (exists $properties->{$WIKIDATA_PROP_IMAGE}) {
            return "File:$properties->{$WIKIDATA_PROP_IMAGE}[0]{mainsnak}{datavalue}{value}";
        } elsif (exists $properties->{$WIKIDATA_PROP_LOGO_IMAGE}) {
            return "File:$properties->{$WIKIDATA_PROP_LOGO_IMAGE}[0]{mainsnak}{datavalue}{value}";
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
