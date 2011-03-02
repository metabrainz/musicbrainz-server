package t::MusicBrainz::Server::Wizard::ReleaseEditor;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Wizard::ReleaseEditor;

test all => sub {

    my $input1 = {
        'length' => '4:03',
        'title' => 'the Love bug',
        'names' => [
            { 'name' => 'm-flo', 'id' => '135345' },
            { 'name' => 'BoA', 'id' => '9496' },
        ]
    };

    my $input2 = {
        'names' => [
            { 'id' => '135345', 'name' => 'm-flo' },
            { 'id' => '9496', 'name' => 'BoA' },
        ],
        'title' => 'the Love bug',
        'length' => '4:03',
    };

    my $result1 = MusicBrainz::Server::Wizard::ReleaseEditor::edit_sha1 ($input1);
    my $result2 = MusicBrainz::Server::Wizard::ReleaseEditor::edit_sha1 ($input2);
    is ($result1, "aIkUXodpaNX7Q1YfttiKMkKCxB0", 'SHA-1 of $input1');
    is ($result2, "aIkUXodpaNX7Q1YfttiKMkKCxB0", 'SHA-1 of $input2');

};

1;
