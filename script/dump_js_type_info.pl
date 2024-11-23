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

my $c = MusicBrainz::Server::Context->create_script_context(database => 'TEST');
my @link_types = $c->model('LinkType')->get_all;
my @link_attribute_types = $c->model('LinkAttributeType')->get_all;

my $json = JSON::XS->new->allow_blessed->convert_blessed->utf8;
my $type_info = $json->encode(\@link_types);
my $attr_info = $json->encode(\@link_attribute_types);

print "Writing root/static/scripts/tests/typeInfo.js ...\n";

open(my $fh, '>', $out_file);
print $fh <<"EOF";
// \@flow strict
// Automatically generated, do not edit.
exports.linkTypes = ($type_info/*: \$ReadOnlyArray<LinkTypeT> */);
exports.linkAttributeTypes = ($attr_info/*: \$ReadOnlyArray<LinkAttrTypeT> */);
EOF
close $fh;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
