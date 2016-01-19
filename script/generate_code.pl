#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use Template;

my $DATA_DIR = "$FindBin::Bin/../lib/MusicBrainz/Server/Data";

my $TT = Template->new(
    INCLUDE_PATH => $DATA_DIR,
);

for my $entity_type (entities_with('aliases')) {
    my $model = $ENTITIES{$entity_type}{model};

    my $vars = {
        entity_type => $entity_type,
        %{ $ENTITIES{"${entity_type}_alias_type"} },
    };

    open my $fh, '>', File::Spec->catfile($DATA_DIR, "${model}AliasType.pm");

    $TT->process('AliasType.tt', $vars, $fh);
}

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2016 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
