use strict;
use warnings;
use Test::LongString;
use Test::More;

use MusicBrainz::Server::Test qw( compare_body );
use MusicBrainz::Server::Types qw( :edit_status );

use aliased 'MusicBrainz::Server::Email::Subscriptions' => 'Email';
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::ArtistSubscription';
use aliased 'MusicBrainz::Server::Entity::LabelSubscription';
use aliased 'MusicBrainz::Server::Entity::EditorSubscription';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Edit';

my $acid2 = Editor->new(
    name => 'acid2',
    email => 'acid2@example.com',
);

subtest 'Edits' => sub {
    my $klute = Artist->new(
        name => 'Klute',
        comment => 'Drum and bass artist',
        gid => 'hello'
    );
    my $klute_sub = ArtistSubscription->new( artist => $klute );
    my @open = (
        Edit->new(status => $STATUS_OPEN),
        Edit->new(status => $STATUS_OPEN)
    );
    my @closed = (Edit->new(status => $STATUS_APPLIED));

    my $email = Email->new(
        editor => $acid2, 
        edits => {
            artist => [{
                subscription => $klute_sub,
                open => \@open,
                applied => \@closed
            }]
        },
    );

    contains_string($email->body,
        sprintf('%s (%s) (%d open, %d applied)',
            $klute->name, $klute->comment, scalar(@open), scalar(@closed)),
        'contains Klutes name and edit count');
    contains_string($email->body => sprintf('/artist/%s/edits', $klute->gid),
        'contains a link to view Klutes edits');
};

subtest 'header' => sub {
    my $email = Email->new(editor => $acid2);
    is($email->subject, 'Edits for your subscriptions');

    contains_string($email->body => '/user/' . $acid2->name . '/subscriptions',
        'appears to have a link to edit subscriptions');
    contains_string($email->body => '/edit/search',
        'has a link to search for edits');
};

subtest 'Deletes and merges' => sub {
    my $artist_id = 124;
    my $label_id = 293;
    my $merge_edit = 991;
    my $delete_edit = 850;
    my $artist_sub = ArtistSubscription->new(
        artist_id => $artist_id,
        deleted_by_edit => $delete_edit
    );
    my $label_sub = LabelSubscription->new(
        label_id => $label_id,
        merged_by_edit => $merge_edit
    );

    my $email = Email->new(
        editor => $acid2, 
        deletes => [ $artist_sub, $label_sub ]
    );

    contains_string($email->body =>
        sprintf('Artist #%d - deleted by edit #%d', $artist_id, $delete_edit),
        'mentions deleted artist');
    contains_string($email->body => "/edit/$delete_edit",
        'has a link to view the deleting edit');

    contains_string($email->body =>
        sprintf('Label #%d - merged by edit #%d', $label_id, $merge_edit),
        'mentions merged label');
    contains_string($email->body => "/edit/$merge_edit",
        'has a link to view the merging edit');
};

done_testing;
