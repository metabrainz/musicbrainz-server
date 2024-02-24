package t::MusicBrainz::Script::Utils;

use strict;
use warnings;

use File::Spec;
use File::Temp qw( tempdir );
use Test::More;
use Test::Routine;

use MusicBrainz::Script::Utils qw( find_mbdump_file );

test 'find_mbdump_file works as expected' => sub {
    my $test = shift;

    my $dir1 = tempdir('find_mbdump_file-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    my $dir2 = File::Spec->catdir($dir1, 'mbdump');
    my $dir3 = File::Spec->catdir($dir1, 'recording');

    system('mkdir', $dir2, $dir3);

    my $f1_path = File::Spec->catfile($dir1, 'artist');
    my $f2_path = File::Spec->catfile($dir2, 'recording');
    my $f3_path = File::Spec->catfile($dir2, 'artist');

    system('touch', $f1_path, $f2_path, $f3_path);

    my ($result, @result);

    $result = find_mbdump_file('dne', $f1_path);
    is($result, undef, 'In scalar context, returns undef for non-existent file');

    @result = find_mbdump_file('dne', $f1_path);
    is(scalar @result, 0, 'In list context, empty list is returned for non-existent file');

    $result = find_mbdump_file('recording', $dir3);
    is($result, undef, 'In scalar context, returns undef for file matching directory name');

    $result = find_mbdump_file('artist', $f1_path);
    is($result, $f1_path, 'Scalar file is found by direct path');

    $result = find_mbdump_file('artist', $dir1);
    is($result, $f1_path, 'Scalar file is found in directory');

    $result = find_mbdump_file('recording', $dir1);
    is($result, $f2_path, 'Scalar file is found in mbdump sub-directory');

    @result = find_mbdump_file('artist', $f1_path, $dir1, $dir2);
    is(scalar @result, 2, 'Two files are found (no duplicates)');
    is($result[0], $f1_path, 'First file is correctly found');
    is($result[1], $f3_path, 'Second file is correctly found');

    unlink $f1_path, $f2_path;
    rmdir($dir1);
    rmdir($dir2);
};

1;
