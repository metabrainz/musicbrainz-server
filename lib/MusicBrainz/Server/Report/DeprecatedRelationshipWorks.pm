package MusicBrainz::Server::Report::DeprecatedRelationshipWorks;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID',
     'MusicBrainz::Server::Report::DeprecatedRelationshipReport';

sub entity_type { 'work' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
