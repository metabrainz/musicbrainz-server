package t::MusicBrainz::Server::Data::CoverArtArchive;

use Test::Deep qw( cmp_deeply );
use Test::Routine;
use MusicBrainz::Server::Test;

with 't::Context';

test 'Calculates S3 policy/signature fields correctly' => sub {
    my $test = shift;

    my $post_fields = $test->c->model('CoverArtArchive')->post_fields(
        'mbid-cdbe40c5-192a-440c-8e68-888dcf884a60',
        'cdbe40c5-192a-440c-8e68-888dcf884a60',
        1000000,
        {expiration => '2015-09-09T00:51:37.000Z',
         access_key => 'foo',
         secret_key => 'bar'},
    );

    cmp_deeply($post_fields, {
        'AWSAccessKeyId' => 'foo',
        'acl' => 'public-read',
        'content-type' => 'image/jpeg',
        'key' => 'mbid-cdbe40c5-192a-440c-8e68-888dcf884a60-1000000.jpg',
        'policy' => 'eyJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJtYmlkLWNkYmU0MGM1LT' .
                    'E5MmEtNDQwYy04ZTY4LTg4OGRjZjg4NGE2MCJ9LHsiYWNsIjoicHVi' .
                    'bGljLXJlYWQifSxbImVxIiwiJGtleSIsIm1iaWQtY2RiZTQwYzUtMT' .
                    'kyYS00NDBjLThlNjgtODg4ZGNmODg0YTYwLTEwMDAwMDAuanBnIl0s' .
                    'WyJzdGFydHMtd2l0aCIsIiRjb250ZW50LXR5cGUiLCJpbWFnZS9qcG' .
                    'VnIl0sWyJlcSIsIiR4LWFyY2hpdmUtYXV0by1tYWtlLWJ1Y2tldCIs' .
                    'IjEiXSxbImVxIiwiJHgtYXJjaGl2ZS1tZXRhLWNvbGxlY3Rpb24iLC' .
                    'Jjb3ZlcmFydGFyY2hpdmUiXSxbImVxIiwiJHgtYXJjaGl2ZS1tZXRh' .
                    'LW1lZGlhdHlwZSIsImltYWdlIl0sWyJlcSIsIiR4LWFyY2hpdmUtbW' .
                    'V0YS1ub2luZGV4IiwidHJ1ZSJdXSwiZXhwaXJhdGlvbiI6IjIwMTUt' .
                    'MDktMDlUMDA6NTE6MzcuMDAwWiJ9',
        'signature' => 'wkU8IRrcTn7BX67kmUDrfDpjnP8=',
        'x-archive-auto-make-bucket' => '1',
        'x-archive-meta-collection' => 'coverartarchive',
        'x-archive-meta-mediatype' => 'image',
        'x-archive-meta-noindex' => 'true',
    });
};

1;
