package MusicBrainz::Server::Controller::Role::Rating;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub ratings : Chained('load') PathPart('ratings')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my @ratings = $c->model($self->{model})->rating->find_by_entity_id($entity->id);
    $c->model('Editor')->load(@ratings);
    $c->model('Editor')->load_preferences(map { $_->editor } @ratings);

    my @public_ratings;
    my $private_rating_count = 0;

    for my $rating (@ratings) {
        if ($rating->editor->preferences->public_ratings) {
            push @public_ratings, $rating;
        } else {
            $private_rating_count++;
        }
    }

    my %props = (
        entity => $entity,
        publicRatings => \@public_ratings,
        privateRatingCount => $private_rating_count,
    );

    $c->stash(
        component_path => 'entity/Ratings',
        component_props => \%props,
        current_view => 'Node',
    );
}

no Moose::Role;
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
