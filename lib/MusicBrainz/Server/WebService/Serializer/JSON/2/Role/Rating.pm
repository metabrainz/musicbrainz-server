package MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating;
use Moose::Role;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( number );

# This allows overriding the "top-level entities only" restriction.
our $forced = 0;

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    return $ret unless $toplevel || $forced;
    return $ret unless defined($inc) && ($inc->ratings || $inc->user_ratings);

    my $opts = $stash->store($entity);

    $ret->{rating} = {
        "votes-count" => defined $opts->{ratings}->{count} ?
            number($opts->{ratings}->{count}) : 0,
        "value" => number($opts->{ratings}->{rating})
    } if $inc->ratings;

    $ret->{"user-rating"} = {
        "value" => number($opts->{"user_ratings"})
    } if $inc->user_ratings;

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012,2017 MetaBrainz Foundation

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

