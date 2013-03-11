package t::MusicBrainz::Server::Email::Subscriptions;
use utf8;
use Test::Routine;
use Test::LongString;
use Test::More;

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Email;

use DBDefs;
use aliased 'MusicBrainz::Server::Entity::Collection';
use aliased 'MusicBrainz::Server::Entity::CollectionSubscription';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Email::Subscriptions' => 'Email';

test all => sub {

    my $editor = Editor->new(
        name => 'ニッキー',
        email => 'somebody@example.com',
        id => 6666
        );

    my $edited_coll = CollectionSubscription->new(
        collection => Collection->new(
            name => 'collection1',
            gid => 'f34c079d-374e-4436-9448-da92dedef3cd'
            )
        );

    my %edits;
    push @{ $edits{ collection } }, {
        open => [1],
        applied => [2, 3],
        subscription => $edited_coll
        };

    my $deleted_coll = CollectionSubscription->new(
        last_seen_name => 'collection2'
        );

    my $email = Email->new(
        editor => $editor,
        edits => \%edits,
        deletes => [$deleted_coll]
        );

    my $text = $email->text;

    ok((grep {"$_" eq 'Message-Id' } $email->extra_headers), 'Has a message-id header');

    my $server = sprintf 'http://%s', DBDefs->WEB_SERVER_USED_IN_EMAIL;
    my $expected = "$server/user/%E3%83%8B%E3%83%83%E3%82%AD%E3%83%BC/subscriptions";

    contains_string($text, $expected, 'Correctly escaped editor name');

    $expected = "collection1 (1 open, 2 applied)\n$server/collection/f34c079d-374e-4436-9448-da92dedef3cd/edits";
    contains_string($text, $expected, 'Correctly displayed collection1 edits and url');

    $expected = "Collection \"collection2\" - deleted or made private";
    contains_string($text, $expected, 'Correctly displayed collection2 as deleted or private');
};

=head1 LICENSE

Copyright (C) 2011-2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1;
