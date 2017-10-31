package MusicBrainz::Script::SampleData;

use base 'Exporter';
use List::MoreUtils qw( uniq );
use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Constants qw( %ENTITIES @RELATABLE_ENTITIES );
use Storable qw( dclone );

our @EXPORT_OK = qw(
    get_popular_entities
    get_sample_entities
);

sub get_popular_entities {
    my ($c, $entity_type) = @_;

    my $joins       = "LEFT JOIN ${entity_type}_tag t ON t.$entity_type = e.id";
    my $group_by    = 'e.id';
    my $popularity  = '(count(t.tag) * coalesce(sum(t.count), 0))';

    my $props = $ENTITIES{$entity_type};
    if ($props->{ratings}) {
        $joins      .= " LEFT JOIN ${entity_type}_meta m ON m.id = e.id";
        $group_by   .= ', coalesce(m.rating_count, 0)';
        $popularity .= ' + (coalesce(m.rating_count, 0) * 500)';
    }

    $c->sql->select_single_column_array(<<"SQL");
        SELECT e.id
          FROM $entity_type e
        $joins
         GROUP BY $group_by
         ORDER BY ($popularity) DESC, e.id ASC
         LIMIT 500;
SQL
}

sub get_sample_entities {
    my $c = shift;

    my %ids;

    my @sample_types = qw(
        area
        artist
        event
        instrument
        label
        place
        recording
        release
        release_group
        series
        work
    );

    for my $entity_type (@sample_types) {
        log("Getting popular $entity_type entities");
        push @{ $ids{$entity_type} }, @{ get_popular_entities($c, $entity_type) };
    }

    # Get areas for all the popular artists.
    log('Getting more sample areas');
    push @{ $ids{area} }, @{ $c->sql->select_single_column_array(<<"SQL", @ids{qw(artist area)}) };
        SELECT a.begin_area
          FROM artist a
         WHERE a.id = any(\$1)
           AND a.begin_area != any(\$2)
           AND a.begin_area IS NOT NULL
        UNION
        SELECT a.end_area
          FROM artist a
         WHERE a.id = any(\$1)
           AND a.end_area != any(\$2)
           AND a.end_area IS NOT NULL
SQL

    # Get release groups for all popular releases.
    log('Getting more sample releases');
    push @{ $ids{release} }, @{ $c->sql->select_single_column_array(<<"SQL", @ids{qw(release release_group)}) };
        SELECT rg.id
          FROM release_group rg
          JOIN release ON release.release_group = rg.id
         WHERE release.id = any(?)
           AND rg.id != any(?)
SQL

    # Get artists for all the popular recordings, releases, and release groups,
    # plus artists with IPIs/ISNIs.
    log('Getting more sample artists');
    push @{ $ids{artist} }, @{ $c->sql->select_single_column_array(<<"SQL", @ids{qw(artist recording release release_group)}) };
        SELECT DISTINCT acn.artist
          FROM artist_credit_name acn
         WHERE acn.artist != any(\$1)
           AND acn.artist_credit IN
               (SELECT artist_credit FROM recording WHERE id = any(\$2)
                UNION
                SELECT artist_credit FROM release WHERE id = any(\$3)
                UNION
                SELECT artist_credit FROM release_group WHERE id = any(\$4))
        UNION
        (SELECT DISTINCT artist FROM artist_ipi WHERE artist != any(\$1) ORDER BY artist LIMIT 100)
        UNION
        (SELECT DISTINCT artist FROM artist_isni WHERE artist != any(\$1) ORDER BY artist LIMIT 100)
SQL

    # Get labels for all releases, plus labels with IPIs, ISNIs, and label codes.
    log('Getting more sample labels');
    push @{ $ids{label} }, @{ $c->sql->select_single_column_array(<<"SQL", @ids{qw(release label)}) };
        SELECT DISTINCT r.label
          FROM release_label r
         WHERE r.release = any(\$1)
           AND r.label != any(\$2)
        UNION
        (SELECT DISTINCT label FROM label_ipi WHERE label != any(\$2) ORDER BY label LIMIT 100)
        UNION
        (SELECT DISTINCT label FROM label_isni WHERE label != any(\$2) ORDER BY label LIMIT 100)
        UNION
        (SELECT id FROM label WHERE label_code IS NOT NULL AND id != any(\$2) ORDER BY id LIMIT 100)
SQL

    # Get some standalone recordings.
    log('Getting more sample recordings');
    push @{ $ids{recording} }, @{ $c->sql->select_single_column_array(<<"SQL", $ids{recording}) };
        SELECT r.id
          FROM recording r
          LEFT JOIN track ON track.recording = r.id
         WHERE track.id IS NULL AND r.id != any(\$1)
         ORDER BY r.id
         LIMIT 100
SQL

    # Get some works with ISWCs and attributes.
    log('Getting more sample works');
    push @{ $ids{work} }, @{ $c->sql->select_single_column_array(<<"SQL", $ids{work}) };
        (SELECT DISTINCT work FROM iswc WHERE work != any(\$1) ORDER BY work LIMIT 100)
        UNION
        (SELECT DISTINCT work FROM work_attribute WHERE work != any(\$1) ORDER BY work LIMIT 100)
SQL

    for my $entity_type (@sample_types) {
        $ids{$entity_type} = [sort { $a <=> $b } uniq @{ $ids{$entity_type} }];
    }

    return \%ids;
}

1;
