package MusicBrainz::Server::Report::DeprecatedRelationshipURLs;
use Moose;

with 'MusicBrainz::Server::Report::URLReport',
     'MusicBrainz::Server::Report::DeprecatedRelationshipReport';

sub entity_type { 'url' }
sub table { 'deprecated_relationship_urls' }
sub component_name { 'DeprecatedRelationshipUrls' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
