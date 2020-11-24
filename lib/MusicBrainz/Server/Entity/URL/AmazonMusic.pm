package MusicBrainz::Server::Entity::URL::AmazonMusic;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

use DBDefs;

sub pretty_name
{
    my $self = shift;

    if ($self->url =~ m{^https://music\.amazon\.(ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|se|sg|com\.tr|co\.uk)/}i) {
        my $country = $1;
        if ($country =~ m/com?\.([a-z]{2})/) {
            $country = $1;
        }
        $country = 'US' if $country eq 'com';
        $country =~ tr/a-z/A-Z/;

        return "Amazon Music ($country)";
    }

    return $self->url->as_string;
}

sub sidebar_name { shift->pretty_name }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
