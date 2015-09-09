package t::MusicBrainz::Server::Data::CoverArtArchive;

use Test::Deep qw( cmp_deeply );
use Test::Routine;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Calculates S3 policy/signature fields correctly' => sub {
    my $test = shift;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO cover_art_archive.image_type (mime_type, suffix)
VALUES ('image/jpeg', 'jpg');
EOSQL

    my $post_fields = $test->c->model('CoverArtArchive')->post_fields(
        'mbid-cdbe40c5-192a-440c-8e68-888dcf884a60',
        'cdbe40c5-192a-440c-8e68-888dcf884a60',
        1000000,
        {expiration => '2015-09-09T00:51:37.000Z'},
    );

    cmp_deeply($post_fields, {
        'AWSAccessKeyId' => 'AKIAJLW34FSQIN4FNWJQ',
        'acl' => 'public-read',
        'content-type' => 'image/jpeg',
        'key' => 'mbid-cdbe40c5-192a-440c-8e68-888dcf884a60-1000000.jpg',
        'policy' => 'eyJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJtYmlkLWNkYmU0MGM1LT' .
                    'E5MmEtNDQwYy04ZTY4LTg4OGRjZjg4NGE2MCJ9LHsiYWNsIjoicHVi' .
                    'bGljLXJlYWQifSxbImVxIiwiJGtleSIsIm1iaWQtY2RiZTQwYzUtMT' .
                    'kyYS00NDBjLThlNjgtODg4ZGNmODg0YTYwLTEwMDAwMDAuanBnIl0s' .
                    'WyJzdGFydHMtd2l0aCIsIiRjb250ZW50LXR5cGUiLCJpbWFnZS9qcG' .
                    'VnIl0sWyJlcSIsIiR4LWFyY2hpdmUtYXV0by1tYWtlLWJ1Y2tldCIs' .
                    'MV0sWyJlcSIsIiR4LWFyY2hpdmUtbWV0YS1jb2xsZWN0aW9uIiwiY2' .
                    '92ZXJhcnRhcmNoaXZlIl0sWyJlcSIsIiR4LWFyY2hpdmUtbWV0YS1t' .
                    'ZWRpYXR5cGUiLCJpbWFnZSJdXSwiZXhwaXJhdGlvbiI6IjIwMTUtMD' .
                    'ktMDlUMDA6NTE6MzcuMDAwWiJ9',
        'signature' => 'tt4mY6ZB4hg4/Q1l39YaBwVdghs=',
        'x-archive-auto-make-bucket' => 1,
        'x-archive-meta-collection' => 'coverartarchive',
        'x-archive-meta-mediatype' => 'image',
    });
};

1;
