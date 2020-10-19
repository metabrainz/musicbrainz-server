package MusicBrainz::Server::Entity::URL::LoC;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

override href_url => sub {
    # Turn the official permalink into what LoC currently redirects to.
    shift->url->as_string =~
        s{^http://id.loc.gov}{https://id.loc.gov}r;
};

sub sidebar_name { 'Library of Congress' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
