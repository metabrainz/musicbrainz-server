package t::MusicBrainz::Script::Utils;

use strict;
use warnings;

use File::Spec;
use File::Temp qw( tempdir );
use Test::More;
use Test::Routine;

use MusicBrainz::Script::Utils qw( find_files find_mbdump_file );

test 'find_files works as expected' => sub {
    my $test = shift;

    my $tmp_dir = tempdir('find_files-XXXXXXXX', DIR => '/tmp', CLEANUP => 1);
    my $sql_dir = File::Spec->catdir($tmp_dir, 'sql');
    my $caa_dir = File::Spec->catdir($sql_dir, 'caa');

    system('mkdir', $sql_dir, $caa_dir);

    my $create_tables_sql_path =
        File::Spec->catfile($caa_dir, 'CreateTables.sql');

    system('touch', $create_tables_sql_path);

    my @result;

    @result = find_files(
        'caa/CreateTables.sql',
        "$caa_dir/CreateTables.sql",
    );
    is(scalar @result, 1, 'one file is found');
    is($result[0], $create_tables_sql_path,
       'file with path prefix is found by direct reference');
};

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
    is($result, undef,
       'undef is returned for non-existent file in scalar context');

    @result = find_mbdump_file('dne', $f1_path);
    is(scalar @result, 0,
       'empty list is returned for non-existent file in list context');

    $result = find_mbdump_file('recording', $dir3);
    is($result, undef,
       'undef is returned for file matching directory name ' .
       'in scalar context');

    $result = find_mbdump_file('artist', $f1_path);
    is($result, $f1_path, 'scalar file is found by direct path');

    $result = find_mbdump_file('artist', $dir1);
    is($result, $f1_path, 'scalar file is found in directory');

    $result = find_mbdump_file('recording', $dir1);
    is($result, $f2_path, 'scalar file is found in mbdump sub-directory');

    @result = find_mbdump_file('artist', $f1_path, $dir1, $dir2);
    is(scalar @result, 2, 'two files are found (no duplicates)');
    is($result[0], $f1_path, 'first file is correctly found');
    is($result[1], $f3_path, 'second file is correctly found');

    unlink $f1_path, $f2_path;
    rmdir($dir1);
    rmdir($dir2);
};

1;
