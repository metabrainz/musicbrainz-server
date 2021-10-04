package MusicBrainz::Server::Controller::Role::EditRelationships;
use JSON;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Constants qw( $SERIES_ORDERING_TYPE_MANUAL );
use MusicBrainz::Server::ControllerUtils::Relationship qw( merge_link_attributes );
use MusicBrainz::Server::Data::Utils qw( model_to_type ref_to_type type_to_model trim non_empty );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Form::Utils qw( build_type_info );

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

    around 'edit_action' => sub {
        my ($orig, $self, $c, %opts) = @_;

        # Only create/edit forms support relationship editing.
        return $self->$orig($c, %opts) unless $opts{edit_rels};

        my $model = $self->config->{model};
        my $source_type = model_to_type($model);
        my $source = $c->stash->{$self->{entity_name}};
        my $source_entity = $source ? $source->TO_JSON : {entityType => $source_type};

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

        my $form_name = "edit-$source_type";

        # Grrr. release_group => release-group.
        $form_name =~ s/_/-/;

        my @link_type_tree = $c->model('LinkType')->get_full_tree;
        my @link_attribute_types = $c->model('LinkAttributeType')->get_all;

        $c->stash(
            source_entity   => $c->json->encode($source_entity),
            attr_info       => $c->json->encode(\@link_attribute_types),
            type_info       => $c->json->encode(build_type_info($c, qr/(^$source_type-|-$source_type$)/, @link_type_tree)),
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
        my %reordered_relationships;

        for my $field (@field_values) {
            my %args;
            my $link_type = $field->{link_type};

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
                        my $orderable_entity = $orderable_direction == 1 ? $relationship->entity1 : $relationship->entity0;
                        my $unorderable_entity = $orderable_direction == 1 ? $relationship->entity0 : $relationship->entity1;
                        my $is_series = $unorderable_entity->isa('MusicBrainz::Server::Entity::Series');

                        if (!$is_series || $unorderable_entity->ordering_type_id == $SERIES_ORDERING_TYPE_MANUAL) {
                            my $key = join '-', $link_type->id, $unorderable_entity->id;

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

            push @edits, $self->reorder_relationships(
                $c, $form,
                link_type_id => $link_type_id,
                relationship_order => $relationship_order,
            );
        }

        return @edits;
    };
};

1;
