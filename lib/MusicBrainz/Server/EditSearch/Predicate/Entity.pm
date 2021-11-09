use MusicBrainz::Server::Constants qw( %ENTITIES @RELATABLE_ENTITIES );

for my $type (@RELATABLE_ENTITIES) {
    my $model = $ENTITIES{$type}{model};
    my $has_subs = $ENTITIES{$type}{subscriptions};
    my $subs_section = '';

    if ($has_subs) {
        $subs_section = <<EOF;
use MusicBrainz::Server::EditSearch::Predicate::Role::Subscribed;
with 'MusicBrainz::Server::EditSearch::Predicate::Role::Subscribed' => {
    type => '$type',
    template_clause => 'EXISTS (
        SELECT TRUE FROM edit_$type
         WHERE ROLE_CLAUSE(edit_$type.$type)
           AND edit_$type.edit = edit.id
    )',
    subscribed_column => '$type'
};
EOF
    }

    # This eval is what actually creates the package. We have to do it because
    # the 'package' function thinks it's a version number if you pass it a
    # string, and we can't interpolate $model any other way than this (the rest
    # could presumably just be done with a normal block).
    eval <<EOF; ## no critic 'ProhibitStringyEval'
package MusicBrainz::Server::EditSearch::Predicate::$model;
use Moose;
use MusicBrainz::Server::EditSearch::Predicate::Role::LinkedEntity;
with 'MusicBrainz::Server::EditSearch::Predicate::Role::LinkedEntity' => { type => '$type' };
$subs_section
with 'MusicBrainz::Server::EditSearch::Predicate';
EOF
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
