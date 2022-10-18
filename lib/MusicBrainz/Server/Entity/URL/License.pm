package MusicBrainz::Server::Entity::URL::License;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

requires 'sidebar_name';

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    $json->{show_license_in_sidebar} =
        boolean_to_json($self->show_license_in_sidebar);

    return $json;
};

=method show_license_in_sidebar

Returns true if this URL should be displayed as a license in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_license_in_sidebar { 1 }

1;
