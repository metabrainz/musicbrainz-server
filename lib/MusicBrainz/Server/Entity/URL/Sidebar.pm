package MusicBrainz::Server::Entity::URL::Sidebar;
use Moose::Role;

requires 'sidebar_name';

=method show_in_sidebar

Returns true if this URL should be displayed in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_in_sidebar { 1 }

1;
