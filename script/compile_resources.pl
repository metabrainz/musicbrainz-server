#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";

use DBDefs;
use Digest::MD5 qw( md5_hex );
use IO::All;
use File::Find;
use MusicBrainz::Server::Data::FileCache;

my $fc = MusicBrainz::Server::Data::FileCache->new;

find(sub {
    $fc->compile_javascript_manifest($_) if ($_ =~ /.js.manifest$/);
    $fc->compile_css_manifest($_)        if ($_ =~ /.css.manifest$/);
}, DBDefs->STATIC_FILES_DIR);

