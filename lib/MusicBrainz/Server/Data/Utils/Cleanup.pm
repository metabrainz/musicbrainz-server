package MusicBrainz::Server::Data::Utils::Cleanup;
use Moose;

use Sub::Exporter -setup => {
    exports => [qw( used_in_relationship )]
};

sub used_in_relationship {
    my ($c, $t, $return) = @_;
    join(
        ' OR ',
        map {
            my ($t0, $t1) = @$_;
            my $predicates = join(
                ' OR ',
                ($t0 eq $t ? "entity0 = $return" : ()),
                ($t1 eq $t ? "entity1 = $return" : ()),
            );
            "EXISTS ( SELECT TRUE FROM l_${t0}_${t1} WHERE $predicates LIMIT 1)";
        } grep { $_->[0] eq $t || $_->[1] eq $t }
            $c->model('Relationship')->all_pairs
    );
}

1;
