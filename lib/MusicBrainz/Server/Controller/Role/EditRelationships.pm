package MusicBrainz::Server::Controller::Role::EditRelationships;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Constants qw(
    $DIRECTION_BACKWARD
    $DIRECTION_FORWARD
    entities_with
);
use MusicBrainz::Server::ControllerUtils::Relationship qw( merge_link_attributes );
use MusicBrainz::Server::Data::Utils qw(
    model_to_type
    non_empty
    ref_to_type
    trim
    type_to_model
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw(
    is_database_row_id
    is_non_negative_integer
    is_positive_integer
    is_guid
);
use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkAttribute';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';
use Readonly;

Readonly our @RELATABLE_MODELS => entities_with(
    ['mbid', 'relatable'],
    take => 'model',
);

role {
    with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

    sub load_entities {
        my ($c, $source_type, @rels) = @_;

        my $entity_map = {};

        my $link_types = $c->model('LinkType')->get_by_ids(
            map { $_->{link_type_id} } @rels
        );

        for my $field (@rels) {
            my $link_type = $link_types->{$field->{link_type_id}};
            my $forward;
            my $target_type;

            if ($link_type && ($source_type eq $link_type->entity0_type ||
                               $source_type eq $link_type->entity1_type)) {
                $forward = $source_type eq $link_type->entity0_type && !$field->{backward};
                $target_type = $forward ? $link_type->entity1_type : $link_type->entity0_type;
                $field->{link_type} = $link_type;
            } elsif ($field->{text}) {
                # If there's a text field, we can assume it's a URL because
                # that's what the text field is for. Seeding URLs without link
                # types is a reasonable use case given that we autodetect them
                # in the JavaScript.
                $forward = $source_type lt 'url';
                $target_type = 'url';
            }

            $field->{forward} = $forward;
            $field->{target_type} = $target_type;

            if ($target_type ne 'url') {
                push @{ $entity_map->{type_to_model($target_type)} //= [] }, $field->{target};
            }
        }

        for my $model (keys %$entity_map) {
            $entity_map->{$model} = $c->model($model)->get_by_gids(@{ $entity_map->{$model} });
        }

        $c->model('SeriesType')->load(values %{ $entity_map->{'Series'} // {} });

        return $entity_map;
    }

    sub get_seeded_relationships {
        my ($c, $source_type, $source) = @_;

        # If the form was posted, seeded relationships (plus any
        # modifications) will have already been saved in localStorage.
        return [] if $c->form_posted;

        my %query_params = %{$c->req->query_params};
        return [] unless %query_params;

        my $seeded_rels = {};
        my @seeded_link_type_ids;
        my @seeded_target_gids;
        my @seeded_attribute_ids;

        for my $param_name (keys %query_params) {
            my ($rel_index, $field_name) =
                ($param_name =~ /^rels\.([0-9]+)\.([0-9a-z_\.]+)$/);

            next unless (defined $rel_index && defined $field_name);

            my $rel = ($seeded_rels->{$rel_index} //= {});
            my $param_value = trim($query_params{$param_name});

            if ($field_name eq 'type') {
                if (
                    is_database_row_id($param_value) ||
                    is_guid($param_value)
                ) {
                    $rel->{type} = $param_value;
                    push @seeded_link_type_ids, $param_value;
                }
                next;
            }

            if ($field_name eq 'target') {
                if (is_guid($param_value)) {
                    $rel->{target_gid} = $param_value;
                    push @seeded_target_gids, $param_value;
                } else {
                    $rel->{target_name} = $param_value;
                }
                next;
            }

            if ($field_name =~ /^(begin_date|end_date)$/) {
                $rel->{$field_name} = $param_value;
                next;
            }

            if ($field_name =~ /^(ended|backward)$/) {
                $rel->{$field_name} = $param_value ? 1 : 0;
                next;
            }

            if ($field_name eq 'link_order') {
                if (is_non_negative_integer($param_value)) {
                    $rel->{$field_name} = 0 + $param_value;
                }
                next;
            }

            my ($attr_index, $attr_field_name) =
                ($field_name =~ /^attributes\.([0-9]+)\.([0-9a-z_\.]+)$/);

            next unless (defined $attr_index && defined $attr_field_name);

            my $attr = ($rel->{attributes}{$attr_index} //= {});

            if ($attr_field_name eq 'type') {
                if (
                    is_database_row_id($param_value) ||
                    is_guid($param_value)
                ) {
                    $attr->{type} = $param_value;
                    push @seeded_attribute_ids, $param_value;
                }
                next;
            }

            if ($attr_field_name =~ /^(credited_as|text_value)$/) {
                $attr->{$attr_field_name} = $param_value;
            }
        }

        my $seeded_link_types = $c->model('LinkType')->get_by_any_ids(@seeded_link_type_ids);
        my $seeded_attributes = $c->model('LinkAttributeType')->get_by_any_ids(@seeded_attribute_ids);
        my @result;

        for my $rel_index (keys %{$seeded_rels}) {
            my $rel = $seeded_rels->{$rel_index};
            my $link_type;
            my $target_gid = $rel->{target_gid};
            my $target_type;
            my $target;

            if ($rel->{type} && ($link_type = $seeded_link_types->{$rel->{type}})) {
                my ($type0, $type1) = ($link_type->entity0_type, $link_type->entity1_type);
                if ($source_type eq $type0) {
                    $target_type = $type1;
                } elsif ($source_type eq $type1) {
                    $target_type = $type0;
                }
                next unless $target_type;
                if ($target_gid) {
                    $target = $c->model(type_to_model($target_type))->get_by_gid($target_gid)
                }
            }

            if ($target_gid && !$target) {
                for my $model (@RELATABLE_MODELS) {
                    $target = $c->model($model)->get_by_gid($target_gid);
                    if (defined $target) {
                        $target_type = $target->entity_type;
                        last;
                    }
                }
            }

            next unless $target_type;

            my $backward = $source_type eq $target_type
                ? ($rel->{backward} // 0)
                : ($source_type lt $target_type ? 0 : 1);

            $target //= $c->model(type_to_model($target_type))->_new_from_row({
                name => $rel->{target_name} // l('[unknown]'),
            });

            my $rel_attributes = $rel->{attributes} // {};
            my @seeded_link_attributes;

            for my $attr_index (keys %{$rel_attributes}) {
                my $attr = $rel_attributes->{$attr_index};

                my $attr_type = $seeded_attributes->{$attr->{type} // ''};
                next unless $attr_type;

                push @seeded_link_attributes, LinkAttribute->new(
                    type_gid => $attr_type->gid,
                    type_id => $attr_type->id,
                    type => $attr_type,
                    $attr_type->creditable && non_empty($attr->{credited_as}) ? (credited_as => $attr->{credited_as}) : (),
                    $attr_type->free_text ? (text_value => ($attr->{text_value} // '')) : (),
                );
            }

            push @result, Relationship->new(
                link => Link->new(
                    defined $link_type ? (
                        type_id => $link_type->id,
                        type => $link_type,
                    ) : (),
                    begin_date => PartialDate->new($rel->{begin_date}),
                    end_date   => PartialDate->new($rel->{end_date}),
                    ended      => $rel->{ended},
                    attributes => \@seeded_link_attributes,
                ),
                $backward ? (
                    defined $source ? (
                        entity1 => $source,
                        entity1_id => $source->id,
                    ) : (),
                    entity0 => $target,
                    defined $target->id ? (entity0_id => $target->id) : (),
                ) : (
                    defined $source ? (
                        entity0 => $source,
                        entity0_id => $source->id,
                    ) : (),
                    entity1 => $target,
                    defined $target->id ? (entity1_id => $target->id) : (),
                ),
                entity0_credit => '',
                entity1_credit => '',
                defined $source ? (source => $source) : (),
                target => $target,
                source_type => $source_type,
                target_type => $target_type,
                source_credit => '',
                target_credit => '',
                link_order => $rel->{link_order} // 0,
                direction => $backward ? $DIRECTION_BACKWARD : $DIRECTION_FORWARD,
            );
        }

        return \@result;
    }

    around 'edit_action' => sub {
        my ($orig, $self, $c, %opts) = @_;

        # Only create/edit forms support relationship editing.
        return $self->$orig($c, %opts) unless $opts{edit_rels};

        my $model = $self->config->{model};
        my $source_type = model_to_type($model);
        my $source = $c->stash->{$self->{entity_name}};
        my $source_entity = $source
            ? $source->TO_JSON
            : {entityType => $source_type, isNewEntity => \1};

        my $form_name = "edit-$source_type";

        # Grrr. release_group => release-group.
        $form_name =~ s/_/-/;

        # XXX Copy any submitted data required by the relationship editor.
        {
            my $name = $c->req->params->{"${form_name}.name"};
            if (non_empty($name)) {
                $source_entity->{name} = $name;
            }
        }
        if ($source_type eq 'series') {
            my $ordering_type_id = $c->req->params->{'edit-series.ordering_type_id'};
            if (is_positive_integer($ordering_type_id)) {
                $source_entity->{orderingTypeID} = 0 + $ordering_type_id;
            }
        }

        if ($source) {
            my @existing_relationships =
                grep {
                    my $lt = $_->link->type;

                    $source->id == $_->entity0_id
                        ? $lt->entity0_cardinality == 0
                        : $lt->entity1_cardinality == 0;

                } sort { $a <=> $b } $source->all_relationships;

            $source_entity->{relationships} = to_json_array(\@existing_relationships);
        }

        $c->stash(
            source_entity => $source_entity,
            seeded_relationships => to_json_array(get_seeded_relationships($c, $source_type, $source)),
        );

        my $post_creation = delete $opts{post_creation};

        $opts{post_creation} = sub {
            my ($edit, $form) = @_;

            my $makes_changes = (
                defined $post_creation && $post_creation->($edit, $form)
            );

            if ($edit) {
                # For edit edit-types, $source is already defined, but its
                # properties may have changed and may be needed by
                # edit_relationships, e.g. series ordering types.
                $source = $c->model($model)->get_by_id($edit->entity_id);
            } elsif (!$source) {
                # If both $edit and $source are undefined, we're on a /create
                # page and the entity wasn't created for some reason (usually
                # because it requires a disambiguation comment).
                return 0;
            }

            my $url_changes = 0;
            if ($form_name ne 'edit-url') {
                my @urls = grep { !$_->is_empty } $form->field('url')->fields;
                $url_changes = $self->edit_relationships($c, $form, \@urls, $source);
            }

            my @rels = grep { !$_->is_empty } $form->field('rel')->fields;
            my $rel_changes = $self->edit_relationships($c, $form, \@rels, $source);

            return 1 if $makes_changes || $url_changes || $rel_changes;
        };

        return $self->$orig($c, %opts);
    };

    method 'edit_relationships' => sub {
        my ($self, $c, $form, $fields, $source) = @_;

        return unless @$fields;

        my @edits;
        my @field_values = map { $_->value } @$fields;
        my $entity_map = load_entities($c, ref_to_type($source), @field_values);
        my $link_types_by_id = {};
        my %reordered_relationships;

        for my $field (@field_values) {
            my %args;
            my $link_type = $field->{link_type};

            $link_types_by_id->{$link_type->id} = $link_type;

            if (my $period = $field->{period}) {
                $args{begin_date} = $period->{begin_date} if $period->{begin_date};
                $args{end_date} = $period->{end_date} if $period->{end_date};
                $args{ended} = $period->{ended} if defined $period->{ended};
            }

            my $relationship;
            if ($field->{relationship_id}) {
                $relationship = $c->model('Relationship')->get_by_id(
                   $link_type->entity0_type, $link_type->entity1_type, $field->{relationship_id}
                );

                # MBS-7354: relationship may have been deleted after the form was created
                defined $relationship or next;

                $c->model('Link')->load($relationship);
                $c->model('LinkType')->load($relationship->link);
                $c->model('Relationship')->load_entities($relationship);

                $args{relationship} = $relationship;
            }

            if (my $attributes = $field->{attributes}) {
                $args{attributes} = merge_link_attributes(
                    $attributes,
                    [$relationship ? $relationship->link->all_attributes : ()]
                );
            }

            unless ($field->{removed}) {
                $args{link_type} = $link_type;

                my $target;

                if ($field->{text}) {
                    $target = $c->model('URL')->find_or_insert($field->{text});
                } elsif ($field->{target}) {
                    $target = $entity_map->{type_to_model($field->{target_type})}->{$field->{target}};
                    next unless $target;
                } elsif ($relationship) {
                    $target = $field->{forward} ? $relationship->entity1 : $relationship->entity0;
                }

                $args{entity0} = $field->{forward} ? $source : $target;
                $args{entity1} = $field->{forward} ? $target : $source;
                $args{entity0_credit} = $field->{entity0_credit} if exists $field->{entity0_credit};
                $args{entity1_credit} = $field->{entity1_credit} if exists $field->{entity1_credit};
                $args{link_order} = $field->{link_order} // 0;
            }

            if ($relationship) {
                if ($field->{removed}) {
                    push @edits, $self->delete_relationship($c, $form, %args);
                } else {
                    push @edits, $self->try_and_edit($c, $form, %args);

                    my $orderable_direction = $link_type->orderable_direction;

                    next if $orderable_direction == 0;
                    next unless non_empty($field->{link_order});

                    if ($field->{link_order} != $relationship->link_order) {
                        if ($relationship->can_manually_reorder) {
                            my $key = join '-', $link_type->id, $relationship->unorderable_entity->id;

                            push @{ $reordered_relationships{$key} //= [] }, {
                                relationship => $relationship,
                                new_order => $field->{link_order},
                                old_order => $relationship->link_order,
                            };
                        }
                    }
                }
            } else {
                push @edits, $self->try_and_insert($c, $form, %args);
            }
        }

        while (my ($key, $relationship_order) = each %reordered_relationships) {
            my ($link_type_id) = split /-/, $key;

            my $link_type = $link_types_by_id->{$link_type_id};

            push @edits, $self->reorder_relationships(
                $c, $form,
                link_type => $link_type,
                relationship_order => $relationship_order,
            );
        }

        return @edits;
    };
};

1;
