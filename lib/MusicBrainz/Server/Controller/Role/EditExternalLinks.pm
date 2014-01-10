package MusicBrainz::Server::Controller::Role::EditExternalLinks;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Data::Utils qw( model_to_type );

parameter 'on_action' => (
    isa => 'Str',
    required => 1,
);

role {
    with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

    my $params = shift;
    my $action = $params->on_action;
    my $target_type = 'url';

    my $url_relationships_data = sub {
        my $entity = shift;

        my @url_relationships = grep { $_->target_type eq $target_type }
            $entity->all_relationships;

        return undef if scalar(@url_relationships) == 0;

        return [
            map +{
                relationship_id => $_->id,
                link_type_id    => $_->link->type_id,
                text            => $_->target->name,

            },
            @url_relationships
        ];
    };

    around "$action" => sub {
        my ($orig, $self, $c) = @_;

        my $source_type = model_to_type($self->config->{model});
        my ($type0, $type1) = sort ($source_type, $target_type);

        my $url_link_types = $c->model('LinkType')->get_tree($type0, $type1);
        my $url_relationships;

        if ($c->form_posted) {
            my $body_params = expand_hash($c->req->body_params);
            $url_relationships = $body_params->{"edit-$source_type"}->{url} // [];
        } else {
            my $source = $c->stash->{$source_type};

            if ($source) {
                $url_relationships = $url_relationships_data->($source);
            }
        }

        $c->stash(
            url_relationships   => $url_relationships // [],
            url_link_types      => $url_link_types,
        );

        return $self->$orig($c);
    };

    around 'edit_action' => sub {
        my ($orig, $self, $c, %opts) = @_;

        my $post_creation = delete $opts{post_creation};

        my $new_post_creation = sub {
            my ($edit, $form) = @_;

            my $makes_changes = (
                defined $post_creation && $post_creation->($edit, $form)
            );

            my $model = $self->config->{model};
            my $source_type = model_to_type($model);

            my $source = $c->stash->{$self->{entity_name}} // (
                $c->model($model)->get_by_id($edit->entity_id)
            );

            $makes_changes ||= $self->edit_external_links($c, $form, $source_type, $source);
            return 1 if $makes_changes;
        };

        $opts{post_creation} = $new_post_creation;
        ($opts{form_args} //= {})->{url_link_types} = $c->stash->{url_link_types};

        return $self->$orig($c, %opts);
    };

    method 'edit_external_links' => sub {
        my ($self, $c, $form, $source_type, $source) = @_;

        my @edits;
        my ($type0, $type1) = sort ($source_type, $target_type);
        my $fields = $form->field('url')->value;

        my $link_types = $c->model('LinkType')->get_by_ids(
            map { $_->{link_type_id} } @$fields
        );

        for my $field (@$fields) {
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
                    $edit = $self->delete($c, $form, %args);
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
