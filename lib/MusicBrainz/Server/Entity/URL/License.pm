package MusicBrainz::Server::Entity::URL::License;
use Moose::Role;
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
