package MusicBrainz::Server::Controller::Role::EditRelationships;
use JSON;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Data::Utils qw( model_to_type ref_to_type type_to_model );
use MusicBrainz::Server::Form::Utils qw( build_type_info build_attr_info );
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';

role {
    with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

    sub serialize_entity {
        my ($source, $type) = @_;

        my $method = "_$type";
        return JSONSerializer->$method($source);
    }

    sub load_entities {
        my ($c, $source_type, @rels) = @_;

        my $entity_map = {};

        my $link_types = $c->model('LinkType')->get_by_ids(
            map { $_->{link_type_id} } @rels
        );

        for (@rels) {
            my $link_type = $link_types->{$_->{link_type_id}};

            my $forward = $source_type eq $link_type->entity0_type && !$_->{backward};
            my $target_type = $forward ? $link_type->entity1_type : $link_type->entity0_type;

            $_->{forward} = $forward;
            $_->{link_type} = $link_type;
            $_->{target_type} = $target_type;

            if ($target_type ne 'url') {
                push @{ $entity_map->{type_to_model($target_type)} //= [] }, $_->{target};
            }
        }

        for my $model (keys %$entity_map) {
            $entity_map->{$model} = $c->model($model)->get_by_gids(@{ $entity_map->{$model} });
        }

        return $entity_map;
    }

    around 'edit_action' => sub {
        my ($orig, $self, $c, %opts) = @_;

        # Only create/edit forms support relationship editing.
        return $self->$orig($c, %opts) unless $opts{edit_rels};

        my $model = $self->config->{model};
        my $source_type = model_to_type($model);
        my $source = $c->stash->{$self->{entity_name}};

        my $submitted_rel_data = sub {
            my @rels = grep {
                $_ && (($_->{text} || $_->{target}) && $_->{link_type_id})
            } @_;

            my @result;
            my $entity_map = load_entities($c, $source_type, @rels);

            for (@rels) {
                my $target_type = $_->{target_type};
                my $target;

                if ($target_type eq 'url') {
                    $target = { name => $_->{text}, entityType => 'url' };
                }
                else {
                    my $serialize = "_$target_type";

                    $target = JSONSerializer->$serialize(
                        $entity_map->{type_to_model($target_type)}->{$_->{target}}
                    );
                }

                push @result, {
                    id          => $_->{relationship_id},
                    linkTypeID  => $_->{link_type_id},
                    removed     => $_->{removed} // 0,
                    attributes  => $_->{attributes} // [],
                    period      => $_->{period} // {},
                    target      => $target,
                };
            }

            # Convert body/query params to the data format used by the
            # JavaScript (same as JSONSerializer->serialize_relationship).
            return \@result;
        };

        my $source_entity = $source ? serialize_entity($source, $source_type) :
                                    { entityType => $source_type };

        if ($source) {
            my @existing_relationships =
                grep {
                    my $lt = $_->link->type;

                    $source == $_->entity0
                        ? $lt->entity0_cardinality == 0
                        : $lt->entity1_cardinality == 0;

                } sort { $a <=> $b } $source->all_relationships;

            $source_entity->{relationships} =
                JSONSerializer->serialize_relationships(@existing_relationships);
        }

        if ($c->form_posted) {
            my $body_params = expand_hash($c->req->body_params);

            $source_entity->{submittedRelationships} = $submitted_rel_data->(
                @{ $body_params->{"edit-$source_type"}->{rel} },
                @{ $body_params->{"edit-$source_type"}->{url} }
            );
        }
        else {
            my $query_params = expand_hash($c->req->query_params);

            my $submitted_relationships = $submitted_rel_data->(
                @{ $query_params->{"edit-$source_type"}->{rel} },
                @{ $query_params->{"edit-$source_type"}->{url} }
            );

            $source_entity->{submittedRelationships} = $submitted_relationships // [];
        }

        my $json = JSON->new;
        my @link_type_tree = $c->model('LinkType')->get_full_tree;
        my $attr_tree = $c->model('LinkAttributeType')->get_tree;

        $c->stash(
            source_entity   => $json->encode($source_entity),
            attr_info       => $json->encode(build_attr_info($attr_tree)),
            type_info       => $json->encode(build_type_info($c, qr/(^$source_type-|-$source_type$)/, @link_type_tree)),
        );

        my $post_creation = delete $opts{post_creation};

        $opts{post_creation} = sub {
            my ($edit, $form) = @_;

            my $makes_changes = (
                defined $post_creation && $post_creation->($edit, $form)
            );

            $source = $source // $c->model($model)->get_by_id($edit->entity_id);
            my @urls = grep { !$_->is_empty } $form->field('url')->fields;
            my @rels = grep { !$_->is_empty } $form->field('rel')->fields;

            my $url_changes = $self->edit_relationships($c, $form, \@urls, $source);
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

        for my $field (@field_values) {
            my $edit;
            my %args;
            my $link_type = $field->{link_type};

            if (my $period = $field->{period}) {
                $args{begin_date} = $period->{begin_date} if $period->{begin_date};
                $args{end_date} = $period->{end_date} if $period->{end_date};
                $args{ended} = $period->{ended} if $period->{ended};
            }

            $args{attributes} = $field->{attributes} if $field->{attributes};
            $args{ended} ||= 0;

            unless ($field->{removed}) {
                $args{link_type} = $link_type;

                my $target;

                if ($field->{text}) {
                    $target = $c->model('URL')->find_or_insert($field->{text});
                } elsif ($field->{target}) {
                    $target = $entity_map->{type_to_model($field->{target_type})}->{$field->{target}};
                }

                $args{entity0} = $field->{forward} ? $source : $target;
                $args{entity1} = $field->{forward} ? $target : $source;;
            }

            if ($field->{relationship_id}) {
                my $relationship = $c->model('Relationship')->get_by_id(
                   $link_type->entity0_type, $link_type->entity1_type, $field->{relationship_id}
                );

                $args{relationship} = $relationship;
                $c->model('Link')->load($relationship);
                $c->model('LinkType')->load($relationship->link);

                if ($field->{removed}) {
                    $edit = $self->delete_relationship($c, $form, %args);
                } else {
                    $edit = $self->try_and_edit($c, $form, %args);
                }
            } else {
                $edit = $self->try_and_insert($c, $form, %args);
            }
            push @edits, $edit;
        }

        return @edits;
    };
};

1;
