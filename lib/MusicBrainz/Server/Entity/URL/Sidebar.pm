package MusicBrainz::Server::Entity::URL::Sidebar;
use Moose::Role;

requires 'sidebar_name';

=method show_in_external_links

Returns true if this URL should be displayed in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_in_external_links { 1 }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
