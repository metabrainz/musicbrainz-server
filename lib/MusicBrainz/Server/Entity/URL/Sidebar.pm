package MusicBrainz::Server::Entity::URL::Sidebar;
use Moose::Role;

requires 'sidebar_name';

=method show_in_external_links

Returns true to display this URL in the sidebar.
Allows subclasses to do per-value checks on URLs.

=cut

sub show_in_external_links { 1 }

1;
