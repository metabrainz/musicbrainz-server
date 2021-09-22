#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Cwd qw( realpath );
use FindBin;
use lib "$FindBin::Bin/../lib";

my $out_file = realpath("$FindBin::Bin/../root/static/scripts/tests/typeInfo.js");
if (-f $out_file) {
    print "Skipping typeInfo.js dump; file already exists at $out_file\n";
    exit 0;
}

use JSON::XS;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Form::Utils qw( build_type_info );

my $c = MusicBrainz::Server::Context->create_script_context(database => 'TEST');
my @link_types = $c->model('LinkType')->get_full_tree;
my @link_attribute_types = $c->model('LinkAttributeType')->get_all;

my $json = JSON::XS->new->allow_blessed->convert_blessed->utf8;
my $type_info = $json->encode(build_type_info($c, qr/.*/, @link_types));
my $attr_info = $json->encode(\@link_attribute_types);

print "Writing root/static/scripts/tests/typeInfo.js ...\n";

open(my $fh, '>', $out_file);
print $fh <<EOF;
// Automatically generated, do not edit.
exports.linkTypeTree = $type_info;
exports.linkAttributeTypes = $attr_info;
EOF
close $fh;
