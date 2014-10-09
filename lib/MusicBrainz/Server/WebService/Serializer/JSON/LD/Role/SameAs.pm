package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::SameAs;
use Moose::Role;

use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( list_or_single );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my @urls;
    if (@{ $entity->relationships_by_type('url') }) {
        push(@urls, grep { defined } map { sameas_url($_) } @{ $entity->relationships_by_type('url') });
    }
 
    if ($entity->can('all_isni_codes') && $entity->all_isni_codes) {
        push(@urls, map { $_->url } $entity->all_isni_codes);
    }

    if (@urls) {
        $ret->{sameAs} = list_or_single(@urls);
    }

    return $ret;
};

sub sameas_url{
    my ($rel) = @_;
    my @acceptable = (
        'fe33d22f-c3b0-4d68-bd53-a856badf2b15', # artist official homepage
        'c550166e-0548-4a18-b1d4-e2ae423a3e88', # artist bandcamp
        'd028a975-000c-4525-9333-d3c8425e4b54', # artist bbc-music

        'fe108f43-acb9-4ad1-8be3-57e6ec5b17b6', # label official site
        'c535de4c-a112-4974-b138-5e0daa56eab5', # label bandcamp
        '1b431eba-0d25-4f27-9151-1bb607f5c8f8', # label blog

        '696b79da-7e45-40e6-a9d4-b31438eb7e5d', # place official homepage
        'e3051f32-527b-4c47-9993-71250a6cd99c', # place blog

        '4f2e710d-166c-480c-a293-2e2c8d658d87', # release amazon asin
        '823656dd-0309-4247-b282-b92d287d59c5', # release discography entry

        '87d97dfc-3206-42fd-89d5-99593d5f1297', # release group official homepage
    );
    my %acceptable = map { $_ => 1 } @acceptable;

    my @acceptable_parents = (
        730, # area other databases

        188, # artist other databases
        185, # artist online community

        218, # label social network
        222, # label other databases
        304, # label video channel

        429, # place social network
        561, # place other databases
        495, # place video channel

        306, # recording other databases

        82,  # release other databases

        96,  # release group other databases

        273, # work other databases
    );
    my %acceptable_parents = map { $_ => 1 } @acceptable_parents;

    if ($acceptable{$rel->link->type->gid} ||
        $acceptable_parents{$rel->link->type->parent_id} ||
        $acceptable_parents{$rel->link->type->id}) {
        return $rel->target->url->as_string;
    }
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

