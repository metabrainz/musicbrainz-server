package t::MusicBrainz::Server::Data::Search;
use Test::Routine;
use Test::Moose;
use Test::More;

use HTTP::Response;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Test::Mock::Class ':all';
use MusicBrainz::Server::Data::Utils qw( type_to_model );

use MusicBrainz::Server::Data::Search;

with 't::Context';

test 'Searching artists with area lookup' => sub {
    my $test = shift;
    my $c = $test->c;

    my $area_name = 'Area';

    my $data = load_data('artist', $c);
    my $artist = $data->{results}[0]{entity};
    is($artist->area->name, $area_name);
};

test all => sub {

my $test = shift;

my $data = load_data('artist', $test->c);

is ( @{$data->{results} }, 25 );

my $artist = $data->{results}->[0]->{entity};

ok ( defined $artist->name );
is ( $artist->name, 'Love' );
is ( $artist->sort_name, 'Love' );
is ( $artist->comment, 'folk-rock/psychedelic band' );
is ( $artist->gid, '34ec9a8d-c65b-48fd-bcdd-aad2f72fdb47' );
is ( $artist->type->name, 'group' );

$data = load_data('release_group', $test->c);

is ( @{$data->{results} }, 25 );

my $release_group = $data->{results}->[0]->{entity};

ok ( defined $release_group->name );
is ( $release_group->name, 'Love' );
is ( $release_group->gid, '1b545f10-b62e-370b-80fc-dba87834836b' );
is ( $release_group->primary_type->name, 'single' );
is ( $release_group->artist_credit->names->[0]->artist->name, 'Anouk' );
is ( $release_group->artist_credit->names->[0]->artist->sort_name, 'Anouk' );
is ( $release_group->artist_credit->names->[0]->artist->gid, '5e8da504-c75b-4bf5-9dfc-119057c1a9c0' );
is ( $release_group->artist_credit->names->[0]->artist->comment, 'Dutch rock singer' );



$data = load_data('release', $test->c);

is ( @{$data->{results} }, 25 );

my $release = $data->{results}->[0]->{entity};

is ( $release->name, 'LOVE' );
is ( $release->gid, '64ea1dca-db9a-4945-ae68-78e02a27b158' );
is ( $release->script->iso_code, 'latn' );
is ( $release->language->iso_code_3, 'eng' );
is ( $release->artist_credit->names->[0]->artist->name, 'HOUND DOG' );
is ( $release->artist_credit->names->[0]->artist->sort_name, 'HOUND DOG' );
is ( $release->artist_credit->names->[0]->artist->gid, 'bd21b7a2-c6b5-45d6-bdb7-18e5de8bfa75' );
is ( $release->mediums->[0]->track_count, 9 );




$data = load_data('recording', $test->c);

is ( @{$data->{results} }, 25 );

my $recording = $data->{results}->[0]->{entity};
my $extra = $data->{results}->[0]->{extra};

is ( $recording->name, 'Love' );
is ( $recording->gid, '701d080c-e2c4-4aca-930e-212960bda76e' );
is ( $recording->length, 236666 );
is ( $recording->artist_credit->names->[0]->artist->name, 'Sixpence None the Richer' );
is ( $recording->artist_credit->names->[0]->artist->sort_name, 'Sixpence None the Richer' );
is ( $recording->artist_credit->names->[0]->artist->gid, 'c2c70ed6-5f10-445c-969f-2c16bc9a4c2e' );

ok ( defined $extra );
is ( @{$extra}, 3 );
is ( $extra->[0]->release_group->primary_type->name, "album" );
is ( $extra->[0]->name, "Sixpence None the Richer" );
is ( $extra->[0]->gid, "24efdbe1-a15d-4cc0-a6d7-59bd1ebbdcc3" );
is ( $extra->[0]->mediums->[0]->tracks->[0]->position, 11 );
is ( $extra->[0]->mediums->[0]->track_count, 12 );


$data = load_data('label', $test->c);

is ( @{$data->{results} }, 25 );
my $label = $data->{results}->[0]->{entity};

is ( $label->name, 'Love Records' );
is ( $label->sort_name, 'Love Records' );
is ( $label->comment, 'Finnish label' );
is ( $label->gid, 'e24ca2f9-416e-42bd-a223-bed20fa409d0' );
is ( $label->type->name, 'production' );



$data = load_data('annotation', $test->c);
is ( @{$data->{results} }, 25 );

my $annotation = $data->{results}->[0]->{entity};
is ( $annotation->parent->name, 'Priscilla Angelique' );
is ( $annotation->parent->gid, 'f3834a4c-5615-429e-b74d-ab3bc400186c' );
is ( $annotation->text, "Soul Love" );



$data = load_data('cdstub', $test->c);

is ( @{$data->{results} }, 25 );
my $cdstub = $data->{results}->[0]->{entity};

is ( $cdstub->artist, 'Love' );
is ( $cdstub->discid, 'BsPKnQO8AqLGwGV4_8RuU9cKYN8-' );
is ( $cdstub->title,  'Out Here');
is ( $cdstub->barcode, '1774209312');
is ( $cdstub->track_count, '17');



$data = load_data('freedb', $test->c);

is ( @{$data->{results} }, 25 );
my $freedb = $data->{results}->[0]->{entity};

is ( $freedb->artist, 'Love' );
is ( $freedb->discid, '2a123813' );
is ( $freedb->title,  'Love');
is ( $freedb->category, 'misc');
is ( $freedb->year, '');
is ( $freedb->track_count, '19');

MusicBrainz::Server::Test->prepare_test_database($test->c, '+release');

my @direct = MusicBrainz::Server::Data::Search->new(c => $test->c)->search(
    'release', 'Blonde on blonde', 25, 0, 0);

my $results = $direct[0];

is ($direct[1], 2, "two search results");
is ($results->[0]->entity->name, 'Blonde on Blonde', 'exact phrase ranked first');
is ($results->[1]->entity->name, 'Blues on Blonde on Blonde', 'longer phrase ranked second');

};

sub load_data
{
    my ($type, $c) = @_;

    ok (type_to_model($type), "$type has a model");

    return MusicBrainz::Server::Data::Search->new(c => $c)->external_search(
        $type,
        'love',  # "Love" always has tons of hits
        25,      # items per page
        0,       # paging offset
        0,       # advanced search
        MusicBrainz::Server::Test::mock_search_server($type)
    );
}

1;
