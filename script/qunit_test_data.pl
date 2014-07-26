#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use JSON;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Form::Utils qw( build_attr_info build_type_info );

my $c = MusicBrainz::Server::Context->create_script_context;
my @link_types = $c->model('LinkType')->get_full_tree;
my $attr_tree = $c->model('LinkAttributeType')->get_tree;

my $json = JSON->new->utf8;
my $type_info = $json->encode(build_type_info($c, qr/.*/, @link_types));
my $attr_info = $json->encode(build_attr_info($attr_tree));

print "Writing root/static/scripts/tests/typeInfo.js ...\n";

open(my $fh, ">", "$FindBin::Bin/../root/static/scripts/tests/typeInfo.js");
print $fh <<EOF;
// Automatically generated, do not edit.
MB.relationshipEditor.exportTypeInfo($type_info, $attr_info);
EOF
close $fh;
