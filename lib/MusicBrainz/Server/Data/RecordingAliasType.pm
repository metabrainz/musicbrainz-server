# Automatically generated, do not edit.
package MusicBrainz::Server::Data::RecordingAliasType;

use Moose;

extends 'MusicBrainz::Server::Data::Entity';

with 'MusicBrainz::Server::Data::Role::AliasType';

sub _id_cache_prefix { 'recording_alias_type' }

sub _table { 'recording_alias_type' }

sub _type { 'recording' }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2016 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
