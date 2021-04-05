package MusicBrainz::Server::Data::Relationship;

use Moose;
use namespace::autoclean;
use Readonly;
use Sql;
use Carp qw( carp croak );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Data::Event;
use MusicBrainz::Server::Data::Instrument;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Link;
use MusicBrainz::Server::Data::LinkType;
use MusicBrainz::Server::Data::Place;
use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Series;
use MusicBrainz::Server::Data::URL;
use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    ref_to_type
    type_to_model
);
use MusicBrainz::Server::Constants qw(
    :direction
    $PART_OF_AREA_LINK_TYPE
    %ENTITIES
    %ENTITIES_WITH_RELATIONSHIP_CREDITS
    @RELATABLE_ENTITIES
    entities_with
);
use Scalar::Util 'weaken';
use List::AllUtils qw( any part uniq );
use List::UtilsBy qw( nsort_by partition_by );
use aliased 'MusicBrainz::Server::Entity::RelationshipTargetTypeGroup';
use aliased 'MusicBrainz::Server::Entity::RelationshipLinkTypeGroup';

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Data::Entity';

my %TYPES = map { $_ => 1} @RELATABLE_ENTITIES;

sub _type { 'relationship' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Relationship';
}

sub _new_from_row
{
    my ($self, $row, $type0, $type1, $obj, $matching_entity_type) = @_;
    my $entity0 = $row->{entity0};
    my $entity1 = $row->{entity1};
    my %info = (
        id => $row->{id},
        link_id => $row->{link},
        edits_pending => $row->{edits_pending},
        entity0_id => $entity0,
        entity1_id => $entity1,
        entity0_credit => $row->{entity0_credit},
        entity1_credit => $row->{entity1_credit},
        last_updated => $row->{last_updated},
        link_order => $row->{link_order},
    );

    my $weaken;
    if (defined $obj) {
        $info{source} = $obj;
        $info{source_type} = $obj->entity_type;

        if ($matching_entity_type == 0 && $entity0 == $obj->id) {
            $weaken = 'entity0';
            $info{entity0} = $obj;
            $info{direction} = $DIRECTION_FORWARD;
            $info{source_credit} = $info{entity0_credit};
            $info{target_credit} = $info{entity1_credit};
            $info{target_type} = $type1;
        }
        elsif ($matching_entity_type == 1 && $entity1 == $obj->id) {
            $weaken = 'entity1';
            $info{entity1} = $obj;
            $info{direction} = $DIRECTION_BACKWARD;
            $info{source_credit} = $info{entity1_credit};
            $info{target_credit} = $info{entity0_credit};
            $info{target_type} = $type0;
        }
        else {
            carp "Neither relationship end-point matched the object.";
        }
    }

    my $rel = MusicBrainz::Server::Entity::Relationship->new(%info);
    # XXX MASSIVE MASSIVE HACK.
    weaken($rel->{$weaken}) if $obj;

    return $rel;
}

sub _check_types
{
    my ($self, $type0, $type1) = @_;

    croak 'Invalid types'
        unless exists $TYPES{$type0} && exists $TYPES{$type1} && $type0 le $type1;
}

sub get_by_id
{
    my ($self, $type0, $type1, $id) = @_;
    $self->_check_types($type0, $type1);

    my $query = "SELECT * FROM l_${type0}_${type1} WHERE id = ?";
    my $row = $self->sql->select_single_row_hash($query, $id)
        or return undef;

    return $self->_new_from_row($row, $type0, $type1);
}

sub get_by_ids
{
    my ($self, $type0, $type1, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $query = "SELECT * FROM l_${type0}_${type1} WHERE id IN (" . placeholders(@ids) . ")";
    my $rows = $self->sql->select_list_of_hashes($query, @ids) or return undef;

    return { map { $_->{id} => $self->_new_from_row($_, $type0, $type1) } @$rows };
}

sub _load
{
    my ($self, $type, $target_types, $use_cardinality, @objs) = @_;
    my @target_types = uniq @$target_types;
    my @types = map { [ sort($type, $_) ] } @target_types;
    my @rels;
    foreach my $t (@types) {
        my $target_type = $type eq $t->[0] ? $t->[1] : $t->[0];
        my %objs_by_id = map { $_->id => $_ }
            grep { @{ $_->relationships_by_type($target_type) } == 0 } @objs;
        my @ids = keys %objs_by_id;
        next unless @ids;

        my $type0 = $t->[0];
        my $type1 = $t->[1];
        my (@cond, @params, $target, $target_id, $source_id, $query);

        if ($type eq $type0) {
            my $condstring = "entity0 IN (" . placeholders(@ids) . ")";
            if ($use_cardinality) {
                $condstring = "($condstring AND entity0_cardinality = 0)";
            }
            push @cond, $condstring;
            push @params, @ids;
            $target = $type1;
            $target_id = 'entity1';
            $source_id = 'entity0';
        }
        if ($type eq $type1) {
            my $condstring = "entity1 IN (" . placeholders(@ids) . ")";
            if ($use_cardinality) {
                $condstring = "($condstring AND entity1_cardinality = 0)";
            }
            push @cond, $condstring;
            push @params, @ids;
            $target = $type0;
            $target_id = 'entity0';
            $source_id = 'entity1';
        }

        # If the source and target types are the same, two possible conditions
        # will have been added above, so join them with an OR.
        @cond = join(" OR ", @cond);

        my $select = "l_${type0}_${type1}.* FROM l_${type0}_${type1}
                      JOIN link l ON link = l.id
                      JOIN link_type lt ON lt.id = l.link_type";

        my $order = 'lt.name,
                     l.begin_date_year, l.begin_date_month, l.begin_date_day,
                     l.end_date_year,   l.end_date_month,   l.end_date_day,
                     l.ended';

        if ($ENTITIES{$target}{sort_name}) {
            $order .= ", ${target}.sort_name COLLATE musicbrainz";
        } elsif ($target eq 'url') {
            $order .= ', url';
        } else {
            $order .= ", ${target}.name COLLATE musicbrainz";
        }

        $query = "SELECT $select
                    JOIN $target ON $target_id = ${target}.id
                   WHERE " . join(" AND ", @cond) . "
                   ORDER BY $order";

        for my $row (@{ $self->sql->select_list_of_hashes($query, @params) }) {
            my $entity0 = $row->{entity0};
            my $entity1 = $row->{entity1};
            if ($type eq $type0 && exists $objs_by_id{$entity0}) {
                my $obj = $objs_by_id{$entity0};
                my $rel = $self->_new_from_row($row, $type0, $type1, $obj, 0);
                $obj->add_relationship($rel);
                push @rels, $rel;
            }
            if ($type eq $type1 && exists $objs_by_id{$entity1}) {
                my $obj = $objs_by_id{$entity1};
                my $rel = $self->_new_from_row($row, $type0, $type1, $obj, 1);
                $obj->add_relationship($rel);
                push @rels, $rel;
            }
        }
    }
    for my $obj (@objs) {
        $obj->has_loaded_relationships(1);
    }
    return @rels;
}

sub _load_related_info {
    my ($self, @rels) = @_;

    $self->c->model('Link')->load(@rels);
    my @links = map { $_->link } @rels;
    $self->c->model('LinkType')->load(@links);
    my @link_types = map { $_->type } @links;
    $self->c->model('LinkType')->load_root_ids(@link_types);
    $self->c->model('LinkAttributeType')->load(map { $_->all_attributes } @link_types);
    $self->load_entities(@rels);
}

Readonly our $DEFAULT_LOAD_PAGED_LIMIT => 100;

sub load_paged {
    my ($self, $source, $target_types, %opts) = @_;

    my $source_type = $source->entity_type;
    my $source_id = $source->id;
    my $limit = $opts{limit} // $DEFAULT_LOAD_PAGED_LIMIT;
    my $offset = $opts{offset} // 0;
    my $link_type_filter = $opts{link_type_id};
    my $direction_filter = $opts{direction};
    my @all_lt_groups;
    my @all_rels;

    for my $target_type (@{$target_types}) {
        # Check if relationships were already loaded for this target type.
        next if exists $source->paged_relationship_groups->{$target_type};

        my ($type0, $type1) = sort($source_type, $target_type);

        my $target_type_group =
            $source->paged_relationship_groups->{$target_type} =
            RelationshipTargetTypeGroup->new;

        for my $side ((
            [$type0, 0, 1, $DIRECTION_FORWARD],
            [$type1, 1, 0, $DIRECTION_BACKWARD],
        )) {
            my ($entity_type, $source_index,
                $target_index, $direction) = @$side;

            next unless $source_type eq $entity_type;

            next if defined $direction_filter &&
                $direction_filter != $direction;

            my $source_column = "entity${source_index}";
            my $target_column = "entity${target_index}";

            my $link_type_counts = $self->get_entity_link_type_counts(
                $type0, $type1,
                $source_column, $source->id,
            );

            my $link_type_groups = $target_type_group->link_type_groups;
            my @link_type_ids = keys %{$link_type_counts};
            my $link_types = $self->c->model('LinkType')->get_by_ids(
                @link_type_ids,
                $link_type_filter ? $link_type_filter : (),
            );

            for my $link_type_id (@link_type_ids) {
                my $total_relationships = $link_type_counts->{$link_type_id};

                my $lt_group = RelationshipLinkTypeGroup->new(
                    link_type => $link_types->{$link_type_id},
                    link_type_id => $link_type_id,
                    direction => $direction,
                    total_relationships => $total_relationships,
                    limit => $limit,
                    offset => $offset,
                );
                my $group_key = "${link_type_id}:${source_column}";
                $link_type_groups->{$group_key} = $lt_group;

                next if (
                    $link_type_filter &&
                    $link_type_id != $link_type_filter
                );

                my (@params, $query);

                my $order = 'l.begin_date_year, l.begin_date_month, l.begin_date_day, ' .
                            'l.end_date_year, l.end_date_month, l.end_date_day, ' .
                            'l.ended';

                if ($ENTITIES{$target_type}{sort_name}) {
                    $order .= ", ${target_type}.sort_name COLLATE musicbrainz";
                } elsif ($target_type eq 'url') {
                    $order .= ', url.url';
                } else {
                    $order .= ", ${target_type}.name COLLATE musicbrainz";
                }

                my $condstring = "l.link_type = ? AND rel.$source_column = ?";
                push @params, $link_type_id, $source_id;

                if ($opts{use_cardinality}) {
                    $condstring .= " AND ${source_column}_cardinality = 0";
                }

                $query = "SELECT rel.* " .
                    "FROM l_${type0}_${type1} rel " .
                    'JOIN link l ON link = l.id ' .
                    "JOIN $target_type ON rel.$target_column = ${target_type}.id " .
                    "WHERE $condstring " .
                    "ORDER BY $order";

                if ($limit) {
                    $query .= ' LIMIT ?';
                    push @params, $limit;
                }

                if ($offset) {
                    $query .= ' OFFSET ?';
                    push @params, $offset;
                }

                my @rels = map {
                    $self->_new_from_row($_, $type0, $type1, $source, $source_index)
                } @{ $self->sql->select_list_of_hashes($query, @params) };
                push @all_rels, @rels;

                $lt_group->relationships(\@rels);
                $lt_group->is_loaded(1);
                push @all_lt_groups, $lt_group;
            }

            # If there are 0 relationships for the filtered link type,
            # return an empty group.
            if (
                defined $link_type_filter &&
                !exists $link_type_counts->{$link_type_filter}
            ) {
                my $group_key = "${link_type_filter}:${source_column}";
                $link_type_groups->{$group_key} = RelationshipLinkTypeGroup->new(
                    link_type => $link_types->{$link_type_filter},
                    link_type_id => $link_type_filter,
                    direction => $direction,
                    total_relationships => 0,
                    limit => $limit,
                    offset => $offset,
                    is_loaded => 1,
                );
            }
        }
    }

    $self->_load_related_info(@all_rels);
    return \@all_lt_groups;
}

sub load_entities
{
    my ($self, @rels) = @_;
    my %ids_by_type;
    foreach my $rel (@rels) {
        if ($rel->entity0_id && !defined($rel->entity0)) {
            my $type = $rel->link->type->entity0_type;
            $ids_by_type{$type} = [] if !exists($ids_by_type{$type});
            push @{$ids_by_type{$type}}, $rel->entity0_id;
        }
        if ($rel->entity1_id && !defined($rel->entity1)) {
            my $type = $rel->link->type->entity1_type;
            $ids_by_type{$type} = [] if !exists($ids_by_type{$type});
            push @{$ids_by_type{$type}}, $rel->entity1_id;
        }
    }

    my %data_by_type;
    foreach my $type (keys %ids_by_type) {
        my @ids = @{$ids_by_type{$type}};
        $data_by_type{$type} =
            $self->c->model(type_to_model($type))->get_by_ids(@ids);
    }

    foreach my $rel (@rels) {
        if ($rel->entity0_id && !defined($rel->entity0)) {
            my $type = $rel->link->type->entity0_type;
            my $obj = $data_by_type{$type}->{$rel->entity0_id};

            if (defined $obj) {
                $rel->entity0($obj);

                if ($rel->direction == $DIRECTION_BACKWARD) {
                    $rel->target($obj);
                    $rel->target_type($type);
                } elsif (!defined $rel->source) {
                    $rel->source($obj);
                    $rel->source_type($type);
                }
            }
        }
        if ($rel->entity1_id && !defined($rel->entity1)) {
            my $type = $rel->link->type->entity1_type;
            my $obj = $data_by_type{$type}->{$rel->entity1_id};

            if (defined $obj) {
                $rel->entity1($obj);

                if ($rel->direction == $DIRECTION_FORWARD) {
                    $rel->target($obj);
                    $rel->target_type($type);
                } elsif (!defined $rel->source) {
                    $rel->source($obj);
                    $rel->source_type($type);
                }
            }
        }
    }

    my @load_ac = grep { $_->meta->find_method_by_name('artist_credit') } map { values %$_ } values %data_by_type;
    $self->c->model('ArtistCredit')->load(@load_ac);

    my @places = values %{$data_by_type{'place'}};
    my @areas = values %{$data_by_type{'area'}};
    $self->c->model('Area')->load(@places);
    $self->c->model('Area')->load_containment(@areas, map { $_->area } @places);

    my @series = values %{$data_by_type{'series'}};
    $self->c->model('SeriesType')->load(@series);
}

sub _load_subset {
    my ($self, $types, $use_cardinality, @objs) = @_;
    my %objs_by_type;
    return unless @objs; # nothing to do
    foreach my $obj (@objs) {
        if (my $type = ref_to_type($obj)) {
            $objs_by_type{$type} = [] if !exists($objs_by_type{$type});
            push @{$objs_by_type{$type}}, $obj;
        }
    }

    my @rels;
    foreach my $type (keys %objs_by_type) {
        push @rels, $self->_load($type, $types, $use_cardinality, @{$objs_by_type{$type}});
    }

    $self->_load_related_info(@rels);

    return @rels;
}

sub load_subset {
    my ($self, $types, @objs) = @_;
    return $self->_load_subset($types, 0, @objs);
}

sub load {
    my ($self, @objs) = @_;
    return $self->_load_subset(\@RELATABLE_ENTITIES, 0, @objs);
}

sub load_cardinal {
    my ($self, @objs) = @_;
    return $self->_load_subset(\@RELATABLE_ENTITIES, 1, @objs);
}

sub load_subset_cardinal {
    my ($self, $types, @objs) = @_;
    return $self->_load_subset($types, 1, @objs);
}

sub generate_table_list {
    my ($self, $type, @end_types) = @_;
    # Generate a list of all possible type combinations
    my @types;
    @end_types = @RELATABLE_ENTITIES unless @end_types;
    foreach my $t (@end_types) {
        if ($type le $t) {
            push @types, ["l_${type}_${t}", 'entity0', 'entity1'];
        }
        if ($type ge $t) {
            push @types, ["l_${t}_${type}", 'entity1', 'entity0'];
        }
    }
    return @types;
}

sub all_pairs
{
    my $self = shift;

    # Generate a list of all possible type combinations
    my @all;
    for my $l0 (@RELATABLE_ENTITIES) {
        for my $l1 (@RELATABLE_ENTITIES) {
            next if $l1 lt $l0;
            push @all, [ $l0, $l1 ];
        }
    }
    return @all;
}

sub merge_entities {
    my ($self, $type, $target_id, $source_ids, %opts) = @_;

    # Delete relationships where the start is the same as the end
    # (after merging)
    my @ids = ($target_id, @$source_ids);
    $self->sql->do(
        "DELETE FROM l_${type}_${type}
         WHERE entity0 = any(\$1) AND entity1 = any(\$1)",
        \@ids
    );

    my @credit_fields = qw(entity0_credit entity1_credit);
    my @date_fields = qw(
        begin_date_year begin_date_month begin_date_day
        end_date_year end_date_month end_date_day ended
    );
    my $comma_sep_date_fields = join ', ', @date_fields;

    my $do_table_merge = sub {
        my ($table, $entity0, $entity1) = @_;

        $self->sql->do("LOCK TABLE $table IN SHARE ROW EXCLUSIVE MODE");

        # Unless the rename_credits option is given, preserve implicit (empty)
        # relationship credits by copying the existing entity names into them.
        if ($ENTITIES_WITH_RELATIONSHIP_CREDITS{$type} && !$opts{rename_credits}) {
            my $target_table = $self->c->model(type_to_model($type))->_main_table;

            $self->sql->do(
                "UPDATE $table SET ${entity0}_credit = target.name
                   FROM $target_table target
                  WHERE ${table}.${entity0}_credit = ''
                    AND target.id = ${table}.${entity0}
                    AND target.id = any(?)",
                $source_ids
            );
        }

        my $relationships = $self->sql->select_list_of_hashes(<<EOSQL, \@ids);
            SELECT * FROM (
                SELECT
                    a.*,
                    link_type,
                    $comma_sep_date_fields,
                    count(*) OVER (PARTITION BY $entity1, link_type, link_order, attributes) AS redundant
                FROM (
                    SELECT id,
                           link,
                           link_order,
                           entity0,
                           entity1,
                           entity0_credit,
                           entity1_credit,
                           array_agg(row(attribute_type, text_value) ORDER BY attribute_type, text_value) attributes
                    FROM $table
                    LEFT JOIN link_attribute la USING (link)
                    LEFT JOIN link_attribute_text_value USING (link, attribute_type)
                    WHERE $entity0 = any(?)
                    GROUP BY id
                ) a
                JOIN link ON link.id = a.link
            ) b WHERE redundant > 1
EOSQL

        # Given a set of duplicate relationship where only one will be kept,
        # determine what {entity0,entity1}_credit should be used. Non-empty
        # credits on the merge target are always preserved. Otherwise, all the
        # non-empty credits must be the same across every relationship. If
        # there's more than one unique credit, it'd be arbitrary to pick one,
        # so an empty string is used instead.
        my $determine_credit = sub {
            my ($prop, $set, $to_keep) = @_;

            if ($to_keep && $to_keep->{$prop} && $to_keep->{$entity0} == $target_id) {
                return $to_keep->{$prop};
            }

            my @uniq_credits = uniq grep { $_ } map { $_->{$prop} } @$set;
            return scalar(@uniq_credits) == 1 ? $uniq_credits[0] : '';
        };

        my $update_credit = sub {
            my ($prop, $relationship, $new_credit) = @_;

            my $old_credit = $relationship->{$prop};

            # Check that:
            # (1) The credit is different from the existing one.
            # (2) If the relationship comes from the merge target, the credit
            #     is currently empty. Non-empty credits on the merge target
            #     are never overwritten.
            if ($new_credit ne $old_credit && !($old_credit && $relationship->{$entity0} == $target_id)) {
                $self->sql->do("UPDATE $table SET $prop = ? WHERE id = ?", $new_credit, $relationship->{id});
                $relationship->{$prop} = $new_credit;
            }
        };

        my $update_documentation_examples = sub {
            my ($to_keep, @to_delete) = @_;

            # MBS-8516
            my $ids_to_delete = [map { $_->{id} } @to_delete];

            $self->sql->do(
                "UPDATE documentation.${table}_example
                    SET id = \$1
                  WHERE id = any(\$2)
                    AND NOT EXISTS (SELECT 1 FROM documentation.${table}_example WHERE id = \$1)",
                $to_keep->{id},
                $ids_to_delete
            );

            $self->sql->do(
                "DELETE FROM documentation.${table}_example WHERE id = any(?)",
                $ids_to_delete
            );
        };

        my $delete_relationships = sub {
            $self->sql->do("DELETE FROM $table WHERE id = any(?)", [map { $_->{id} } @_]);
        };

        my $merge_dupes = sub {
            return @_ unless @_ > 1;

            # Prefer keeping relationships on the merge target, so non-empty
            # credits on them are preserved.
            my ($to_keep, @to_delete) = nsort_by { $_->{$entity0} == $target_id ? 0 : $_->{id} } @_;

            $update_credit->($_, $to_keep, $determine_credit->($_, \@_, $to_keep)) for @credit_fields;
            $update_documentation_examples->($to_keep, @to_delete);
            $delete_relationships->(@to_delete);

            return $to_keep;
        };

        my %possible_dupes = partition_by {
            join "\t", @{$_}{$entity1, qw(link_type link_order)}, @{$_->{attributes}}
        } @$relationships;

        while (my ($key, $possible_dupes) = each %possible_dupes) {
            my %definite_dupes = partition_by { join "\t", @{$_}{$entity1, 'link'} } @$possible_dupes;

            # Merge relationships that are exact duplicates other than credits,
            # and group the remaining ones by $entity0.
            my %by_source = partition_by { $_->{$entity0} } map { $merge_dupes->(@$_) } values %definite_dupes;

            # Delete relationships where:
            # a.) there is no date set (no begin or end date, and the ended flag is off), and
            # b.) there is no relationship on the same pre-merge entity which
            #     *does* have a date, since this indicates the quasi-duplication
            #     may be intentional
            my (@non_empty_dates, @empty_dates);
            for my $by_source (values %by_source) {
                # Make sure the entity doesn't contain both a dated and non-dated relationship, per (b) above.
                my ($non_empty_dates, $empty_dates) = part { (any { $_ } @{$_}{@date_fields}) ? 0 : 1 } @$by_source;

                push @non_empty_dates, @$non_empty_dates if defined $non_empty_dates && !defined $empty_dates;
                push @empty_dates, @$empty_dates if defined $empty_dates && !defined $non_empty_dates;
            }

            if (@non_empty_dates) {
                # Everything in @empty_dates will be deleted, but we may want to copy over credits on them.
                my %empty_dates_credits = map { $_ => $determine_credit->($_, \@empty_dates) } @credit_fields;

                for my $r (@non_empty_dates) {
                    for my $prop (@credit_fields) {
                        $update_credit->($prop, $r, $empty_dates_credits{$prop}) unless $r->{$prop};
                    }
                }

                $update_documentation_examples->($non_empty_dates[0], @empty_dates);
                $delete_relationships->(@empty_dates);
            }

            # No need to merge @empty_dates together. They'd have had the same
            # link and been grouped together in %definite_dupes above.
        }

        # Move all remaining relationships
        $self->sql->do(
            "UPDATE $table SET $entity0 = ? WHERE $entity0 = any(?)",
            $target_id, \@ids
        );
    };

    foreach my $t ($self->generate_table_list($type)) {
        $do_table_merge->(@$t);
    }
}

sub delete_entities
{
    my ($self, $type, @ids) = @_;

    foreach my $t ($self->generate_table_list($type)) {
        my ($table, $entity0, $entity1) = @$t;
        $self->sql->do("
            DELETE FROM $table a
            WHERE $entity0 IN (" . placeholders(@ids) . ")
        ", @ids);
    }
}

=method exists

Checks if a relationship with the given values already exists. This doesn't
consider entity credits, because those don't determine uniqueness at the
database level.

Returns a relationship ID, if one exists.

=cut

sub exists {
    my ($self, $type0, $type1, $values) = @_;

    $self->_check_types($type0, $type1);

    my @props = qw(entity0 entity1 link_order link);
    my @values = @{$values}{qw(entity0_id entity1_id link_order)};

    my $link = $self->c->model('Link')->find({
        link_type_id => $values->{link_type_id},
        begin_date => $values->{begin_date},
        end_date => $values->{end_date},
        ended => $values->{ended},
        attributes => $values->{attributes},
    });

    return 0 unless $link;
    push @values, $link;

    return $self->sql->select_single_value(
        "SELECT id FROM l_${type0}_${type1} WHERE " . join(' AND ', map { "$_ = ?" } @props),
        @values
    );
}

sub _check_series_type {
    my ($self, $series_id, $link_type_id, $entity_type) = @_;

    my $link_type = $self->c->model('LinkType')->get_by_id($link_type_id);
    return if $link_type->orderable_direction == 0;

    my $series = $self->c->model('Series')->get_by_id($series_id);
    $self->c->model('SeriesType')->load($series);

    if ($series->type->item_entity_type ne $entity_type) {
        die "Incorrect entity type for part of series relationship";
    }
}

sub insert
{
    my ($self, $type0, $type1, $values) = @_;
    $self->_check_types($type0, $type1);

    $self->_check_series_type($values->{entity0_id}, $values->{link_type_id}, $type1) if $type0 eq "series";
    $self->_check_series_type($values->{entity1_id}, $values->{link_type_id}, $type0) if $type1 eq "series";

    my $row = {
        link => $self->c->model('Link')->find_or_insert({
            link_type_id => $values->{link_type_id},
            begin_date => $values->{begin_date},
            end_date => $values->{end_date},
            ended => $values->{ended},
            attributes => $values->{attributes},
        }),
        entity0 => $values->{entity0_id},
        entity1 => $values->{entity1_id},
        entity0_credit => $values->{entity0_credit} // '',
        entity1_credit => $values->{entity1_credit} // '',
        link_order => $values->{link_order} // 0,
    };
    my $id = $self->sql->insert_row("l_${type0}_${type1}", $row, 'id');

    if ($type0 eq "series") {
        $self->c->model('Series')->automatically_reorder($values->{entity0_id});
    }

    if ($type1 eq "series") {
        $self->c->model('Series')->automatically_reorder($values->{entity1_id});
    }

    return $self->_entity_class->new( id => $id );
}

sub update
{
    my ($self, $type0, $type1, $id, $values) = @_;
    $self->_check_types($type0, $type1);

    my %link = map {
        $_ => $values->{$_};
    } qw( link_type_id begin_date end_date attributes ended );

    my $old = $self->sql->select_single_row_hash(
        "SELECT link, entity0, entity1 FROM l_${type0}_${type1} WHERE id = ?", $id
    );

    my $new = {};
    $new->{entity0} = $values->{entity0_id} if $values->{entity0_id};
    $new->{entity1} = $values->{entity1_id} if $values->{entity1_id};
    $new->{entity0_credit} = $values->{entity0_credit} if defined $values->{entity0_credit};
    $new->{entity1_credit} = $values->{entity1_credit} if defined $values->{entity1_credit};

    my $series0 = $type0 eq "series";
    my $series1 = $type1 eq "series";
    my $entity0_changed = $new->{entity0} && $old->{entity0} != $new->{entity0};
    my $entity1_changed = $new->{entity1} && $old->{entity1} != $new->{entity1};
    my $series0_changed = $series0 && $entity0_changed;
    my $series1_changed = $series1 && $entity1_changed;

    $self->_check_series_type($new->{entity0}, $link{link_type_id}, $type1) if $series0_changed;
    $self->_check_series_type($new->{entity1}, $link{link_type_id}, $type0) if $series1_changed;

    $new->{link} = $self->c->model('Link')->find_or_insert(\%link);
    $self->sql->update_row("l_${type0}_${type1}", $new, { id => $id });

    $self->c->model('Series')->automatically_reorder($old->{entity0}) if $series0_changed;
    $self->c->model('Series')->automatically_reorder($old->{entity1}) if $series1_changed;

    $self->c->model('Series')->automatically_reorder($new->{entity0})
        if $series0_changed || ($series0 && $old->{link} != $new->{link});

    $self->c->model('Series')->automatically_reorder($new->{entity1})
        if $series1_changed || ($series1 && $old->{link} != $new->{link});

    $self->delete_entity_link_type_counts(
        $type0,
        $type1,
        $new->{entity0},
        $new->{entity1},
    );
}

sub delete
{
    my ($self, $type0, $type1, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $series_col;
    $series_col = "entity0" if $type0 eq "series";
    $series_col = "entity1" if $type1 eq "series";

    my $deleted = $self->sql->select_list_of_hashes(
        "DELETE FROM l_${type0}_${type1} " .
        "WHERE id IN (" . placeholders(@ids) . ") " .
        "RETURNING entity0, entity1",
        @ids,
    );

    for my $row (@$deleted) {
        $self->delete_entity_link_type_counts(
            $type0,
            $type1,
            $row->{entity0},
            $row->{entity1},
        );
        if (defined $series_col) {
            $self->c->model('Series')->automatically_reorder($row->{$series_col});
        }
    }
}

sub adjust_edit_pending
{
    my ($self, $type0, $type1, $adjust, @ids) = @_;
    $self->_check_types($type0, $type1);

    my $query = "UPDATE l_${type0}_${type1}
                 SET edits_pending = numeric_larger(0, edits_pending + ?)
                 WHERE id IN (" . placeholders(@ids) . ")";
    $self->sql->do($query, $adjust, @ids);
}

sub reorder {
    my ($self, $type0, $type1, %ordering) = @_;

    my @ids = keys %ordering;

    # Given a list of relationship ids, extract their unordered entities
    # (i.e. a series is unordered, its releases are), plus the link_type ids
    # they use.
    #
    # Then select *all* relationships that use any of those (entity, link_type)
    # pairs in a relationship, which gives us are orderable groups.
    #
    # If more than one group is returned, something is wrong, since this
    # function is only intended to be able to order one group.

    my $groups = $self->sql->select_list_of_hashes(
        "SELECT DISTINCT (CASE WHEN olt.direction = 1
                               THEN r.entity0
                               ELSE r.entity1 END) AS source,
                         lt.id AS link_type
         FROM l_${type0}_${type1} r
         JOIN link l ON l.id = r.link
         JOIN link_type lt ON lt.id = l.link_type
         JOIN orderable_link_type olt ON olt.link_type = lt.id
         WHERE r.id = any(?)",
        \@ids
    );

    die "Can only reorder one group of relationships" if @$groups != 1;

    $self->sql->do(
        "WITH pos (relationship, link_order) AS (
            VALUES " . join(', ', ('(?::INTEGER, ?::INTEGER)') x @ids) . "
        )
        UPDATE l_${type0}_${type1} SET link_order = pos.link_order
        FROM pos WHERE pos.relationship = id",
        %ordering
    );
}

=method lock_and_do

Lock the corresponding relationship table for $type0-$type in ROW EXCLUSIVE
mode, and run a block of code.

=cut

sub lock_and_do {
    my ($self, $type0, $type1, $code) = @_;

    my ($t0, $t1) = sort($type0, $type1);
    Sql::run_in_transaction(sub {
        $code->();
    }, $self->c->sql);
}

sub get_entity_link_type_counts {
    my ($self, $type0, $type1, $side, $entity_id) = @_;

    $self->_check_types($type0, $type1);

    die 'side must be entity0 or entity1'
        unless $side =~ /^entity[01]$/;
    die 'entity_id must be defined'
        unless defined $entity_id;

    my $cache_key = "entity_link_type_counts:$type0:$type1:$side:$entity_id";
    my $cache = $self->c->cache($self->_type);
    my $data = $cache->get($cache_key);

    return $data if defined $data;

    my $rows = $self->sql->select_list_of_hashes(
        'SELECT link.link_type, count(*) as l_count ' .
        "FROM l_${type0}_${type1} r " .
        'JOIN link ON r.link = link.id ' .
        "WHERE r.$side = ? " .
        'GROUP BY link.link_type',
        $entity_id,
    );

    $data = { map { $_->{link_type} => $_->{l_count} } @$rows };
    $cache->set($cache_key, $data);
    return $data;
}

sub delete_entity_link_type_counts {
    my ($self, $type0, $type1, $entity0_id, $entity1_id) = @_;

    $self->_check_types($type0, $type1);

    die 'entity0_id must be defined'
        unless defined $entity0_id;
    die 'entity1_id must be defined'
        unless defined $entity1_id;

    my $cache_key_prefix = "entity_link_type_counts:$type0:$type1";
    $self->c->cache($self->_type)->delete_multi(
        "$cache_key_prefix:entity0:$entity0_id",
        "$cache_key_prefix:entity1:$entity1_id",
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Relationship

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
