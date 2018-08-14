package MusicBrainz::Server::Controller::Role::WikipediaExtract;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use List::UtilsBy qw( rev_nsort_by );
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;

    $c->stash->{wikipedia_extract} = $self->_get_extract($c, 1);
};

sub wikipedia_extract : Chained('load') PathPart('wikipedia-extract')
{
    my ($self, $c) = @_;

    my $wp_extract = $self->_get_extract($c, 0);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->res->content_type('application/json; charset=utf-8');
    $c->res->{body} = $c->json_utf8->encode({wikipediaExtract => $wp_extract});
}

sub _get_extract
{
    my ($self, $c, $cache_only) = @_;

    my $entity = $c->stash->{entity};
    my $wanted_lang = $c->stash->{current_language} // 'en';
    # Remove country codes, at least for now
    $wanted_lang =~ s/[_-][A-Za-z]+$//;

    # Choose an AR to use:
    #  * find all Wikipedia and Wikidata relationships
    #  * prefer wikidata relationships
    #  * except, if we have a matching-language wikipedia link, use it instead,
    #    since then we don't have to do a query for languages
    my @links = map {
            $_->target;
        } rev_nsort_by {
            if ($_->target->isa('MusicBrainz::Server::Entity::URL::Wikipedia') &&
                $_->target->language eq $wanted_lang) { 2; }
            elsif ($_->target->isa('MusicBrainz::Server::Entity::URL::Wikidata')) { 1; }
            else { 0; }
        } grep {
            $_->target->isa('MusicBrainz::Server::Entity::URL::Wikipedia') ||
            $_->target->isa('MusicBrainz::Server::Entity::URL::Wikidata')
        } @{ $entity->relationships_by_link_type_names('wikipedia', 'wikidata') };

    if (scalar @links) {
        $c->model('EditorLanguage')->load_for_editor($c->user) if $c->user_exists;
        return $c->model('WikipediaExtract')->get_extract(\@links,
            $wanted_lang,
            editor => $c->user,
            cache_only => $cache_only);
    }
    return;
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Ian McEwen
Copyright (C) 2012 MetaBrainz Foundation

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
