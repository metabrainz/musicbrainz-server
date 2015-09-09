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
                    'IjEiXSxbImVxIiwiJHgtYXJjaGl2ZS1tZXRhLWNvbGxlY3Rpb24iLC' .
                    'Jjb3ZlcmFydGFyY2hpdmUiXSxbImVxIiwiJHgtYXJjaGl2ZS1tZXRh' .
                    'LW1lZGlhdHlwZSIsImltYWdlIl1dLCJleHBpcmF0aW9uIjoiMjAxNS' .
                    '0wOS0wOVQwMDo1MTozNy4wMDBaIn0=',
        'signature' => 'TAzJWfuoxlFhXlmHJFaoI4Bu89s=',
        'x-archive-auto-make-bucket' => '1',
        'x-archive-meta-collection' => 'coverartarchive',
        'x-archive-meta-mediatype' => 'image',
    });
};

1;
