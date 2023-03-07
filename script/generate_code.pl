#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use Template;

my $SERVER_DIR = "$FindBin::Bin/../lib/MusicBrainz/Server";

my $TT = Template->new(
    INCLUDE_PATH => $SERVER_DIR,
);

for my $entity_type (entities_with('aliases')) {
    my $model = $ENTITIES{$entity_type}{model};
    my $alias_type = "${entity_type}_alias_type";

    my $vars = {
        alias_type => $alias_type,
        %{ $ENTITIES{$alias_type} },
    };

    my $fh;
    open $fh, '>', File::Spec->catfile($SERVER_DIR, "Data/${model}AliasType.pm");
    $TT->process('Data/AliasType.tt', $vars, $fh);

    open $fh, '>', File::Spec->catfile($SERVER_DIR, "Entity/${model}AliasType.pm");
    $TT->process('Entity/AliasType.tt', $vars, $fh);
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
