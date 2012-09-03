package MusicBrainz::Server::Entity::URL::ASIN;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

use DBDefs;

sub pretty_name
{
    my $self = shift;

    if ($self->url =~ m{^http://(?:www.)?(.*?\.)([a-z]+)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i) {
        my $country = $2;
        $country = "US" if $country eq "com";
        $country =~ tr/a-z/A-Z/;

        return "$country: $3";
    }

    return $self->url->as_string;
}

sub sidebar_name { shift->pretty_name }

sub affiliate_url {
    my $self = shift;
    my $url = $self->url;
    if ($url =~ m{^http://(?:.*?\.)(amazon\.([a-z\.]+))(?:\:[0-9]+)?/[^?]+$}i) {
        my $ass_id = DBDefs->AWS_ASSOCIATE_ID($1);
        return $url unless $ass_id;
        return URI->new("$url?tag=$ass_id");
    } else {
        return $url;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
