package MusicBrainz::Server::Entity::URL::License;
use Moose::Role;

requires 'sidebar_name';

=method show_license_in_sidebar

Returns true if this URL should be displayed as a license in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_license_in_sidebar { 1 }

1;
