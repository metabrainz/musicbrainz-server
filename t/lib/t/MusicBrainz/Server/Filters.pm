package t::MusicBrainz::Server::Filters;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Filters qw( format_editnote );

test 'Edit note syntax' => sub {
    is(format_editnote("'''bold'''"), '<strong>bold</strong>');
    is(format_editnote("''italic''"), '<em>italic</em>');
    is(format_editnote("'''''bold + italic'''''"), '<em><strong>bold + italic</strong></em>');
    is(format_editnote("<script>alert('in ur edit notez')</script>"),
       "&lt;script&gt;alert('in ur edit notez')&lt;/script&gt;");
};

1;
