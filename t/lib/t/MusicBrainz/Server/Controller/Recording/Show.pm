package t::MusicBrainz::Server::Controller::Recording::Show;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', 'fetch recording');
html_ok($mech->content);
$mech->title_like(qr/King of the Mountain/, 'title has recording name');
$mech->content_like(qr/King of the Mountain/, 'content has recording name');
$mech->content_like(qr/4:54/, 'has recording duration');
$mech->content_like(qr{1\.1}, 'track position');
$mech->content_like(qr{United Kingdom}, 'release country');
$mech->content_like(qr{DEE250800230}, 'ISRC');
$mech->content_like(qr{2005-11-07}, 'release date 1');
$mech->content_like(qr{2005-11-08}, 'release date 2');
$mech->content_like(qr{/release/f205627f-b70a-409d-adbe-66289b614e80}, 'link to release 1');
$mech->content_like(qr{/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b}, 'link to release 2');
$mech->content_like(qr{/artist/4b585938-f271-45e2-b19a-91c634b5e396}, 'link to artist');
$mech->content_like(qr{<a href="[^"]+">guitar</a>:}, 'relationships');

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'fetch dancing queen recording');
html_ok($mech->content);
$mech->title_like(qr/Dancing Queen/);
$mech->content_contains('Test annotation 3', 'has annotation');

page_test_jsonld $mech => {
    'isrcCode' => 'DEE250800231',
    '@id' => 'http://musicbrainz.org/recording/123c079d-374e-4436-9448-da92dedef3ce',
    '@context' => 'http://schema.org',
    '@type' => 'MusicRecording',
    'sameAs' => 'http://musicbrainz.org/recording/0986e67c-6b7a-40b7-b4ba-c9d7583d6426',
    'name' => 'Dancing Queen',
    'duration' => 'PT02M03S'
};

};

test 'Embedded JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+recording-6b517117-8b98-463b-9457-f8e3a08d1f49');

    $mech->get_ok('/recording/6b517117-8b98-463b-9457-f8e3a08d1f49', 'fetch dancing queen recording');

    page_test_jsonld $mech => {
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/recording/6b517117-8b98-463b-9457-f8e3a08d1f49',
        '@type' => 'MusicRecording',
        'contributor' => [
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/001363e3-f643-4aca-bb95-3075cdcf62c8',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Lori Holton-Nash'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/0a51af30-5e31-470e-abd2-dd979a3e3d80',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Donnie Lyle'
                },
                'roleName' => 'guitars'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/134d3aac-76f7-4652-993e-932d01256d49',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Yvonne Gage'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/19c882f5-a6ec-488f-b6ad-ab489eddc655',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Kendall Nesbitt'
                },
                'roleName' => 'keyboard'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/1c7a3225-2c5a-402e-a988-786b06ef5013',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Steve Robinson'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/2373f554-6a1e-46f9-bac2-8bab5e86b7de',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Percy Bady'
                },
                'roleName' => 'keyboard'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/2387a257-4b30-4af0-af33-d7e5eaa0b5f9',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Paul Riser'
                },
                'roleName' => 'conductor'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/273d6cda-312f-41fa-bf7e-837d51181172',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Felicia Coleman-Evans'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/2c92addd-868b-4c3c-b886-0ed7a6ee3a6b',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Jeffrey W. Morrow'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/3de09330-f53d-4faa-ae92-726866ab9c96',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Deletrice Alexander'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/5f906ee6-fc04-4e90-8141-66f32e5da3cf',
                    '@type' => 'MusicGroup',
                    'name' => 'Walt Whitman & The Soul Children of Chicago'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/690d39ad-7512-4abd-82b8-1885ed255a4b',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Paul Mabin'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/99c9d990-6b02-4600-93a2-66ff9c078f34',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Robin Robinson'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/b7ce9a76-0abc-4f3a-b841-4a7b06f56268',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Joan Collaso'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/c7ea517c-efbb-453b-abd2-5e368f6e5475',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'John Rutledge'
                },
                'roleName' => 'choir vocals'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/c84ebed5-c70c-454f-9a66-31030d311e75',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Hart Hollman'
                }
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/eb65b73a-00f8-475b-beb4-a09cf5cd7a00',
                    '@type' => 'MusicGroup',
                    'name' => 'The Motown Romance Orchestra'
                },
                'roleName' => 'orchestra'
            },
            {
                '@type' => 'OrganizationRole',
                'contributor' => {
                    '@id' => 'http://musicbrainz.org/artist/f9231d98-6e7d-4afd-b2cf-9a656a260f85',
                    '@type' => ['Person', 'MusicGroup'],
                    'name' => 'Simbryt Whittington'
                },
                'roleName' => 'choir vocals'
            },
        ],
        'duration' => 'PT04M38S',
        'isrcCode' => 'USJI10100576',
        'name' => q(The World's Greatest),
        'producer' => {
            '@id' => 'http://musicbrainz.org/artist/c2d25856-a09a-4d15-b404-77dd19c19e63',
            '@type' => ['Person', 'MusicGroup'],
            'name' => 'R. Kelly'
        },
        'recordingOf' => {
            '@id' => 'http://musicbrainz.org/work/2025da95-23f1-31ae-b991-088834e6ce2f',
            '@type' => 'MusicComposition',
            'name' => q(The World's Greatest)
        }
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
