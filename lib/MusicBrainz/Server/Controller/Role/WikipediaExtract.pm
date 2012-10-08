package MusicBrainz::Server::Controller::Role::WikipediaExtract;
use Moose::Role;
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $wp_link = shift @{ $entity->relationships_by_link_type_names('wikipedia') };

    if ($wp_link) {
        my $wanted_lang = $c->stash->{current_language} // 'en';
        if ($self->isa('MusicBrainz::Server::Controller::Work')) {
            $wp_link = $wp_link->entity0;
        } else {
            $wp_link = $wp_link->entity1;
        }

        my $wp_extract = $c->model('WikipediaExtract')->get_extract($wp_link->page_name, $wanted_lang, $wp_link->language);
        if ($wp_extract) {
            $c->stash->{wikipedia_extract} = $wp_extract;
        }
    }
};
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
