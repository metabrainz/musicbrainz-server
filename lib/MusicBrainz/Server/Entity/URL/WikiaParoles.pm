package MusicBrainz::Server::Entity::URL::WikiaParoles;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

override href_url => sub {
    # Turn the official permalink into what LyricWiki currently redirects to.
    # See https://community.fandom.com/wiki/Help:Fandom_domain_migration for more info
    shift->url->as_string =~
        s{^https?://fr\.lyrics\.wikia\.com/}{https://lyrics.fandom.com/fr/}r;
};

sub sidebar_name { 'WikiaParoles' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
