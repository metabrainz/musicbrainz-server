package MusicBrainz::Server::Data::WikidataProperties;
use Moose;
use namespace::autoclean;

use Readonly;

with 'MusicBrainz::Server::Data::Role::MediaWikiAPI';

Readonly my $WIKIDATA_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_wikidata_properties {
    my ($self, $entity, $property) = @_;

    my $url_pattern = "https://www.wikidata.org/w/api.php?action=wbgetclaims&format=json&entity=%s%s";
    return $self->_fetch_cache_or_url($url_pattern,
                                      "wikidata_property",
                                      $WIKIDATA_CACHE_TIMEOUT,
                                      $entity,
                                      undef,
                                      \&_wikidata_properties_callback);
}

sub _wikidata_properties_callback {
    my (%opts) = @_;
    return $opts{fetched}{content} if $opts{fetched}{content};
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2016 MetaBrainz Foundation

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
