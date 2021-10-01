package MusicBrainz::Server::Controller::Role::CommonsImage;
use DBDefs;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use namespace::autoclean;
use Readonly;

requires 'load';

Readonly my $WIKIDATA_PROP_IMAGE => 'P18';
Readonly my $WIKIDATA_PROP_LOGO_IMAGE => 'P154';
Readonly my $WIKIDATA_PROP_LOCATOR_MAP_IMAGE => 'P242';

after load => sub {
    my ($self, $c) = @_;

    $c->stash->{commons_image} = to_json_object($self->_get_commons_image($c, 1));
};

sub commons_image : Chained('load') PathPart('commons-image') {
    my ($self, $c) = @_;

    my $image = $self->_get_commons_image($c, 0);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->res->content_type('application/json; charset=utf-8');
    $c->res->{body} = $c->json->encode({image => $image});
}

sub _get_commons_image {
    my ($self, $c, $cache_only) = @_;

    return unless DBDefs->WIKIMEDIA_COMMONS_IMAGES_ENABLED;

    my $entity = $c->stash->{entity};
    my $title;

    # Check if there's a Wikimedia Commons relationship
    my ($commons_link) = map {
            $_->target;
        } grep {
            $_->target->isa('MusicBrainz::Server::Entity::URL::Commons')
        } @{ $entity->relationships_by_link_type_names('image', 'logo') };
    if ($commons_link) {
        $title = $commons_link->page_name;
    }

    # and if not, check Wikidata entity
    $title = _get_wikidata_image($c) if !$title;

    # Return early if no image exists.
    return unless defined $title;

    return $c->model('CommonsImage')->get_commons_image($title, cache_only => $cache_only);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
