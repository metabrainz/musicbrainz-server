package t::MusicBrainz::Server::Email::Subscriptions;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::LongString;
use Test::More;

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Email;

use MusicBrainz::Server::Translation qw( get_collator );

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
        collator => get_collator('root'),
        edits => \%edits,
        deletes => [$deleted_coll]
        );

    my $text = $email->text;

    ok((grep {"$_" eq 'Message-Id' } $email->extra_headers), 'Has a message-id header');

    my $server = sprintf 'https://%s', DBDefs->WEB_SERVER_USED_IN_EMAIL;
    my $expected = "$server/user/%E3%83%8B%E3%83%83%E3%82%AD%E3%83%BC/subscriptions";

    contains_string($text, $expected, 'Correctly escaped editor name');

    $expected = "collection1 (1 open, 2 applied)\n$server/collection/f34c079d-374e-4436-9448-da92dedef3cd/edits";
    contains_string($text, $expected, 'Correctly displayed collection1 edits and url');

    $expected = 'Collection "collection2" - deleted or made private';
    contains_string($text, $expected, 'Correctly displayed collection2 as deleted or private');
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
