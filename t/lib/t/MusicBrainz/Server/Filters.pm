package t::MusicBrainz::Server::Filters;
use Test::Routine;
use Test::More;

use utf8;

use MusicBrainz::Server::Filters qw( format_editnote format_wikitext );

test 'Edit note syntax' => sub {
    is(format_editnote("'''bold'''"), '<strong>bold</strong>', 'triple-quotes produce bold');
    is(format_editnote("''italic''"), '<em>italic</em>', 'double-quotes produce italics');
    is(format_editnote("'''''bold + italic'''''"), '<em><strong>bold + italic</strong></em>', 'double and triple quotes together produce bold + italic');
    is(format_editnote("<script>alert('in ur edit notez')</script>"),
       "&lt;script&gt;alert('in ur edit notez')&lt;/script&gt;", 'script tags are sanitized');

    is(format_editnote("http://musicbrainz.org"),
       '<a href="http://musicbrainz.org">http://musicbrainz.org</a>', 'plain-http links are created');

    is(format_editnote("https://musicbrainz.org"),
       '<a href="https://musicbrainz.org">https://musicbrainz.org</a>', 'https links are created');

    is(format_editnote("I <3 https://musicbrainz.org"),
       'I &lt;3 <a href="https://musicbrainz.org">https://musicbrainz.org</a>',
       'Links are created, whitespace is preserved, angular brackets are escaped');

    is(format_editnote("I <3 //musicbrainz.org"),
       'I &lt;3 <a href="//musicbrainz.org">//musicbrainz.org</a>',
       'Schema independent links are created, whitespace is preserved, angular brackets are escaped');

    is(format_editnote("//musicbrainz.org"),
       '<a href="//musicbrainz.org">//musicbrainz.org</a>');

    is(format_editnote("foo://musicbrainz.org"),
       'foo://musicbrainz.org',
       'Only http://, https://, and // match');

    is(format_editnote("www.musicbrainz.org"),
       '<a href="http://www.musicbrainz.org">www.musicbrainz.org</a>', 'links marked only by www. get linked');

    is(format_editnote("http://allmusic.com/artist/house-of-lords-p4516/biography"),
       '<a href="http://allmusic.com/artist/house-of-lords-p4516/biography">http://allmusic.com/artist/house-of-lords-p4516/&#8230;</a>');

    is(format_editnote("http://en.wikipedia.org/wiki/House_of_Lords_(band%29"),
       '<a href="http://en.wikipedia.org/wiki/House_of_Lords_(band)">http://en.wikipedia.org/wiki/House_of_Lords_(band)</a>');

    is(format_editnote("http://www.billboard.com/artist/house-of-lords/4846#/artist/house-of-lords/bio/4846"),
       '<a href="http://www.billboard.com/artist/house-of-lords/4846#/artist/house-of-lords/bio/4846">http://www.billboard.com/artist/house-of-lords/4&#8230;</a>');

    is(format_editnote("http://www.discogs.com/artist/House+Of+Lords+(2%29"),
       '<a href="http://www.discogs.com/artist/House+Of+Lords+(2)">http://www.discogs.com/artist/House+Of+Lords+(2)</a>');

    is(format_editnote("Problems with this edit\n\n1."),
       "Problems with this edit<br/><br/>1.", 'newlines -> br');

    like(format_editnote("Please see edit   1"),
         qr{Please see <a href=".*">edit #1</a>}, 'edit links work with many spaces');
};

test 'Wiki documentation syntax' => sub {
    for my $type (qw( artist label recording release release-group url work )) {
        my $mbid = 'b3b1e2b3-cbb8-4b46-a7d0-0031ec13492c';
        like(format_wikitext("[$type:$mbid]"),
             qr{<a href="/$type/$mbid/">$type:$mbid</a>}, "plain [$type:mbid] links");
        like(format_wikitext("[$type:$mbid|alt text]"),
             qr{<a href="/$type/$mbid/">alt text</a>}, "[$type:mbid|text] links");
    }
};

1;
