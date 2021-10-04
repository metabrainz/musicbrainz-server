package MusicBrainz::Server::Data::WikidataProperties;
use Moose;
use namespace::autoclean;

use Readonly;

with 'MusicBrainz::Server::Data::Role::MediaWikiAPI';

Readonly my $WIKIDATA_CACHE_TIMEOUT => 60 * 60 * 24 * 3; # 3 days

sub get_wikidata_properties {
    my ($self, $entity, $property) = @_;

    my $url_pattern = 'https://www.wikidata.org/w/api.php?action=wbgetclaims&format=json&entity=%s%s';
    return $self->_fetch_cache_or_url($url_pattern,
                                      'wikidata_property',
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
