package MusicBrainz::Server::Entity::URL::Sidebar;
use Moose::Role;
use namespace::autoclean;

requires 'sidebar_name';

=method show_in_external_links

Returns true if this URL should be displayed in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_in_external_links { 1 }

1;
