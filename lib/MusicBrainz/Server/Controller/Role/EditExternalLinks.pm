package MusicBrainz::Server::Controller::Role::EditExternalLinks;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Data::Utils qw( model_to_type );

sub build_type_info {
    my $root = shift;
    my $result = {};
    my $build;

    $build = sub {
        my $child = shift;
        my $entity1_type = $child->entity1_type;

        my $phrase_attr = defined $entity1_type && $entity1_type eq 'url'
            ? 'l_link_phrase' : 'l_reverse_link_phrase';

        $result->{$child->id} = {
            gid => $child->gid,
            deprecated => $child->is_deprecated,
            description => $child->l_description,
            phrase => $child->$phrase_attr,
        } if $child->id;

        $build->($_) for $child->all_children;
    };

    $build->($root) if $root;
    return $result;
}

role {
    with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

    my $target_type = 'url';

    sub url_relationships_data {
        my $entity = shift;

        my $url_relationships = $entity->relationships_by_type('url');
        return [] if scalar(@$url_relationships) == 0;

        return [
            map {
                my $type0 = $_->link->type->entity0_type;
                my $type1 = $_->link->type->entity1_type;
                {
                    id            => $_->id,
                    type0         => $type0,
                    type1         => $type1,
                    linkTypeID    => $_->link->type_id,
                    entity0ID     => $type0 eq 'url' ? $_->entity0->utf8_decoded : $_->entity0->gid,
                    entity1ID     => $type1 eq 'url' ? $_->entity1->utf8_decoded : $_->entity1->gid,
                };
            } @$url_relationships
        ];
    }

    around 'edit_action' => sub {
        my ($orig, $self, $c, %opts) = @_;

        my $model = $self->config->{model};
        my $source_type = model_to_type($model);
        my ($type0, $type1) = sort ($source_type, $target_type);
        my $source = $c->stash->{$self->{entity_name}};

        my $url_link_types = $c->model('LinkType')->get_tree($type0, $type1);
        my $url_relationships;

        my $submitted_url_data = sub {
            my $urls = shift;

            # Convert body/query params to the data format used by the
            # JavaScript (same as `url_relationships_data`).
            return [
                map +{
                    id          => $_->{relationship_id},
                    type0       => $type0,
                    type1       => $type1,
                    linkTypeID  => $_->{link_type_id},
                    entity0ID   => $type0 eq 'url' ? $_->{text} : $source ? $source->gid : undef,
                    entity1ID   => $type1 eq 'url' ? $_->{text} : $source ? $source->gid : undef,
                    removed     => $_->{removed} // 0,

                }, @{ $urls // [] }
            ];
        };

        if ($c->form_posted) {
            my $body_params = expand_hash($c->req->body_params);

            $url_relationships = $submitted_url_data->(
                $body_params->{"edit-$source_type"}->{url}
            );
        }
        else {
            my $query_params = expand_hash($c->req->query_params);

            $url_relationships = $submitted_url_data->(
                $query_params->{"edit-$source_type"}->{url}
            );

            if ($source) {
                $url_relationships = [
                    @{ url_relationships_data($source) },
                    @{ $url_relationships // [] }
                ];
            }
        }

        $c->stash(
            url_relationships   => $url_relationships // [],
            url_type_info       => build_type_info($url_link_types),
        );

        my $post_creation = delete $opts{post_creation};

        $opts{post_creation} = sub {
            my ($edit, $form) = @_;

            my $makes_changes = (
                defined $post_creation && $post_creation->($edit, $form)
            );

            $source = $source // $c->model($model)->get_by_id($edit->entity_id);

            my $ext_links_changes = $self->edit_external_links($c, $form, $source_type, $source);
            return 1 if $makes_changes || $ext_links_changes;
        };

        ($opts{form_args} //= {})->{url_link_types} = $url_link_types;

        return $self->$orig($c, %opts);
    };

    method 'edit_external_links' => sub {
        my ($self, $c, $form, $source_type, $source) = @_;

        my @edits;
        my ($type0, $type1) = sort ($source_type, $target_type);

        my $url_field = $form->field('url');
        return unless $url_field;

        my $link_types = $c->model('LinkType')->get_by_ids(
            map { $_->{link_type_id} } @{ $url_field->value }
        );

        for my $field (@{ $url_field->value }) {
            my $edit;
            my $link_type = $link_types->{$field->{link_type_id}};
            my %args = ( type0 => $type0, type1 => $type1 );

            unless ($field->{removed}) {
                $args{link_type} = $link_type;

                my $target = $c->model('URL')->find_or_insert($field->{text});

                $args{entity0} = $source_type le $target_type ? $source : $target;
                $args{entity1} = $source_type le $target_type ? $target : $source;;
            }

            if ($field->{relationship_id}) {
                my $relationship = $c->model('Relationship')->get_by_id(
                   $type0, $type1, $field->{relationship_id}
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
                $args{ended} = 0;
                $edit = $self->try_and_insert($c, $form, %args);
            }
            push @edits, $edit;
        }

        return @edits;
    };
};

1;
