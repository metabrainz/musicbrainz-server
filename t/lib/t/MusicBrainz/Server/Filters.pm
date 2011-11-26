package t::MusicBrainz::Server::Filters;
use Test::Routine;
use Test::More;

use utf8;

use MusicBrainz::Server::Filters qw( format_editnote );

test 'Edit note syntax' => sub {
    is(format_editnote("'''bold'''"), '<strong>bold</strong>');
    is(format_editnote("''italic''"), '<em>italic</em>');
    is(format_editnote("'''''bold + italic'''''"), '<em><strong>bold + italic</strong></em>');
    is(format_editnote("<script>alert('in ur edit notez')</script>"),
       "&lt;script&gt;alert('in ur edit notez')&lt;/script&gt;");

    is(format_editnote("http://musicbrainz.org"),
       '<a href="http://musicbrainz.org">http://musicbrainz.org</a>');

    is(format_editnote("https://musicbrainz.org"),
       '<a href="https://musicbrainz.org">https://musicbrainz.org</a>');

    is(format_editnote("www.musicbrainz.org"),
       '<a href="http://www.musicbrainz.org">www.musicbrainz.org</a>');

    is(format_editnote("http://allmusic.com/artist/house-of-lords-p4516/biography"),
       '<a href="http://allmusic.com/artist/house-of-lords-p4516/biography">http://allmusic.com/artist/house-of-lords-p4516/&#8230;</a>');

    is(format_editnote("http://en.wikipedia.org/wiki/House_of_Lords_(band%29"),
       '<a href="http://en.wikipedia.org/wiki/House_of_Lords_(band)">http://en.wikipedia.org/wiki/House_of_Lords_(band)</a>');

    is(format_editnote("http://www.billboard.com/artist/house-of-lords/4846#/artist/house-of-lords/bio/4846"),
       '<a href="http://www.billboard.com/artist/house-of-lords/4846#/artist/house-of-lords/bio/4846">http://www.billboard.com/artist/house-of-lords/4&#8230;</a>');

    is(format_editnote("http://www.discogs.com/artist/House+Of+Lords+(2%29"),
       '<a href="http://www.discogs.com/artist/House+Of+Lords+(2)">http://www.discogs.com/artist/House+Of+Lords+(2)</a>');
};

1;
