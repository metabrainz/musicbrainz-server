package MusicBrainz::Server::Controller::WS::js::Edit;
use DBDefs;
use File::Spec::Functions qw( catdir );
use HTML::Entities qw( encode_entities );
use JSON qw( encode_json );
use List::MoreUtils qw( any );
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_RELEASEGROUP_EDIT
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_EDIT
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_RECORDING_EDIT
    $EDIT_RELEASE_REORDER_MEDIUMS
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_WORK_CREATE
    $UNTRUSTED_FLAG
    $WS_EDIT_RESPONSE_OK
    $WS_EDIT_RESPONSE_NO_CHANGES
);
use MusicBrainz::Server::ControllerUtils::Relationship qw( merge_link_attributes );
use MusicBrainz::Server::Data::Utils qw(
    boolean_from_json
    type_to_model
    model_to_type
    partial_date_to_hash
    split_relationship_by_attributes
    sanitize
    trim
    trim_comment
    trim_multiline_text
    non_empty
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Renderer qw( render_component );
use MusicBrainz::Server::Translation qw( comma_list comma_only_list l );
use MusicBrainz::Server::Validation qw(
    is_database_row_id
    is_guid
    is_valid_url
    is_valid_partial_date
);
use MusicBrainz::Server::View::Base;
use Readonly;
use Scalar::Util qw( looks_like_number );
use Try::Tiny;
use URI;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';
BEGIN { extends 'MusicBrainz::Server::Controller' }

no if $] >= 5.018, warnings => 'experimental::smartmatch';

Readonly our $ERROR_NOT_LOGGED_IN => 1;
Readonly our $ERROR_NON_EXISTENT_ENTITIES => 2;

our $ALLOWED_EDIT_TYPES = [
    $EDIT_RELEASE_CREATE,
    $EDIT_RELEASE_EDIT,
    $EDIT_RELEASE_ADDRELEASELABEL,
    $EDIT_RELEASE_ADD_ANNOTATION,
    $EDIT_RELEASE_DELETERELEASELABEL,
    $EDIT_RELEASE_EDITRELEASELABEL,
    $EDIT_RELEASEGROUP_CREATE,
    $EDIT_RELEASEGROUP_EDIT,
    $EDIT_MEDIUM_CREATE,
    $EDIT_MEDIUM_EDIT,
    $EDIT_MEDIUM_DELETE,
    $EDIT_MEDIUM_ADD_DISCID,
    $EDIT_RECORDING_EDIT,
    $EDIT_RELEASE_REORDER_MEDIUMS,
    $EDIT_RELATIONSHIP_CREATE,
    $EDIT_RELATIONSHIP_EDIT,
    $EDIT_RELATIONSHIP_DELETE,
    $EDIT_WORK_CREATE,
];

our $TT = Template->new(
    INCLUDE_PATH => catdir(DBDefs->MB_SERVER_ROOT, 'root'),

    VARIABLES => {
        comma_list => sub { my $items = shift; comma_list(@$items) },
        comma_only_list => sub { my $items = shift; comma_only_list(@$items) },
    },

    %{ MusicBrainz::Server->config->{'View::Default'} }
);


sub load_entity_prop {
    my ($loader, $data, $prop, $model) = @_;

    $loader->($data->{$prop}, $model, sub { $data->{$prop} = shift });
}


our $data_processors = {

    $EDIT_RELEASE_CREATE => sub {
        my ($c, $loader, $data) = @_;

        process_entity($c, $loader, $data);
        process_release_events($data->{events});
    },

    $EDIT_RELEASE_EDIT => sub {
        my ($c, $loader, $data) = @_;

        process_entity($c, $loader, $data);
        process_release_events($data->{events});
        load_entity_prop($loader, $data, 'to_edit', 'Release');
    },

    $EDIT_RELEASE_ADDRELEASELABEL => sub {
        my ($c, $loader, $data) = @_;

        process_release_label($c, $loader, $data);
        load_entity_prop($loader, $data, 'release', 'Release');
        load_entity_prop($loader, $data, 'label', 'Label') if $data->{label};
    },

    # MBS-11428: Keep it synced with MusicBrainz::Server::Form::Annotation
    $EDIT_RELEASE_ADD_ANNOTATION => sub {
        my ($c, $loader, $data) = @_;

        process_annotation($c, $loader, $data);
        load_entity_prop($loader, $data, 'entity', 'Release');
    },

    $EDIT_RELEASE_DELETERELEASELABEL => sub {
        my ($c, $loader, $data) = @_;

        load_entity_prop($loader, $data, 'release_label', 'ReleaseLabel');
    },

    $EDIT_RELEASE_EDITRELEASELABEL => sub {
        my ($c, $loader, $data) = @_;

        load_entity_prop($loader, $data, 'release_label', 'ReleaseLabel');
        load_entity_prop($loader, $data, 'label', 'Label') if $data->{label};
    },

    $EDIT_MEDIUM_CREATE => sub {
        my ($c, $loader, $data) = @_;

        process_medium($c, $loader, $data);

        load_entity_prop($loader, $data, 'release', 'Release');
    },

    $EDIT_MEDIUM_EDIT => sub {
        my ($c, $loader, $data) = @_;

        process_medium($c, $loader, $data);

        load_entity_prop($loader, $data, 'to_edit', 'Medium');
    },

    $EDIT_MEDIUM_DELETE => sub {
        my ($c, $loader, $data) = @_;

        load_entity_prop($loader, $data, 'medium', 'Medium');
    },

    $EDIT_MEDIUM_ADD_DISCID => sub {
        my ($c, $loader, $data) = @_;

        load_entity_prop($loader, $data, 'release', 'Release');
    },

    # MBS-11428: Keep it synced with MusicBrainz::Server::Form::Recording
    $EDIT_RECORDING_EDIT => sub {
        my ($c, $loader, $data) = @_;

        process_entity($c, $loader, $data);
        load_entity_prop($loader, $data, 'to_edit', 'Recording');
    },

    $EDIT_RELATIONSHIP_CREATE => \&process_relationship,

    $EDIT_RELATIONSHIP_EDIT => \&process_relationship,

    $EDIT_RELEASE_REORDER_MEDIUMS => sub {
        my ($c, $loader, $data) = @_;

        load_entity_prop($loader, $data, 'release', 'Release');
    },

    # MBS-11428: Keep it synced with MusicBrainz::Server::Form::ReleaseGroup
    $EDIT_RELEASEGROUP_CREATE => \&process_entity,

    # MBS-11428: Keep it synced with MusicBrainz::Server::Form::ReleaseGroup
    $EDIT_RELEASEGROUP_EDIT => sub {
        my ($c, $loader, $data) = @_;

        process_entity($c, $loader, $data);

        $data->{to_edit} = delete $data->{gid};
        load_entity_prop($loader, $data, 'to_edit', 'ReleaseGroup');
    },

    # MBS-11428: Keep it synced with MusicBrainz::Server::Form::Work
    $EDIT_WORK_CREATE => \&process_entity,
};


sub trim_string {
    my ($data, $name) = @_;
    $data->{$name} = trim($data->{$name}) if $data->{$name};
}

sub trim_multiline_string {
    my ($data, $name) = @_;
    $data->{$name} = trim_multiline_text($data->{$name}) if $data->{$name};
}

sub process_annotation {
    my ($c, $loader, $data) = @_;

    trim_multiline_string($data, 'text');
}

sub process_entity {
    my ($c, $loader, $data) = @_;

    if (exists $data->{name}) {
        trim_string($data, 'name');
        die 'empty name' unless non_empty($data->{name});
    }

    if ($data->{comment}) {
        $data->{comment} = trim_comment($data->{comment});
        # MBS-7963
        $data->{comment} = substr($data->{comment}, 0, 255);
    }

    process_artist_credit($c, $loader, $data);
}

sub process_release_label {
    my ($c, $loader, $data) = @_;

    trim_string($data, 'catalog_number');
}

sub process_release_events {
    my ($events) = @_;

    return unless $events && @$events;

    for my $event (@$events) {
        $event->{date} = clean_partial_date($event->{date}) if $event->{date};
    }
}

sub process_artist_credits {
    my ($c, $loader, @artist_credits) = @_;

    my @artist_ids;

    for my $ac (@artist_credits) {
        my @names = @{ $ac->{names} };
        my $i = 0;

        for my $name (@names) {
            if (my $join_phrase = $name->{join_phrase}) {
                $join_phrase = sanitize($join_phrase);
                $join_phrase =~ s/\s+$// if $i == $#names;
                $name->{join_phrase} = $join_phrase;
            }
            my $artist = $name->{artist};

            trim_string($name, 'name');
            trim_string($artist, 'name');

            if (is_database_row_id($artist->{id}))  {
                push @artist_ids, $artist->{id};
            } elsif (is_guid($artist->{gid})) {
                push @artist_ids, $artist->{gid};
            }
            $i++;
        }
    }

    my $artists = $c->model('Artist')->get_by_any_ids(@artist_ids);

    for my $ac (@artist_credits) {
        my @names = @{ $ac->{names} };

        for my $name (@names) {
            my $artist = $name->{artist};
            my $given_id = $artist->{id};
            my $given_gid = $artist->{gid};
            my $entity =
                (defined $given_id ? $artists->{$given_id} : undef) //
                (defined $given_gid ? $artists->{$given_gid} : undef);

            if (defined $entity) {
                $artist->{id} = $entity->id;
                $artist->{gid} = $entity->gid;
                $artist->{name} = $entity->name;
                $name->{name} = $entity->name
                    unless non_empty($name->{name});
            }
        }
    }
}

sub process_artist_credit {
    my ($c, $loader, $data) = @_;

    process_artist_credits($c, $loader, $data->{artist_credit})
        if defined $data->{artist_credit};
}

sub process_medium {
    my ($c, $loader, $data) = @_;

    trim_string($data, 'name');

    if (defined $data->{tracklist}) {
        my @tracks = @{ $data->{tracklist} };
        my @recording_gids = grep { $_ } map { $_->{recording_gid} } @tracks;
        my $recordings = $c->model('Recording')->get_by_gids(@recording_gids);

        my $process_track = sub {
            my $track = shift;

            process_entity($c, $loader, $track);
            trim_string($track, 'number');

            if (my $recording_gid = delete $track->{recording_gid}) {
                $track->{recording} = $recordings->{$recording_gid};
                $track->{recording_id} = $recordings->{$recording_gid}->id;
            }

            delete $track->{id} unless defined $track->{id};

            my $ac = $track->{artist_credit};
            $track->{artist_credit} = ArtistCredit->from_array($ac->{names}) if $ac;
            $track->{is_data_track} = boolean_from_json($track->{is_data_track});

            return Track->new(%$track);
        };

        $data->{tracklist} = [ map { $process_track->($_) } @tracks ];
    }
}

sub clean_partial_date {
    my ($date) = @_;

    return undef unless ref($date) eq 'HASH';

    my $clean = {};
    for (qw( year month day )) {
        $clean->{$_} = $date->{$_} if non_empty($date->{$_});
    }

    my ($year, $month, $day) = @$clean{'year', 'month', 'day'};
    die "invalid date: $year-$month-$day" unless is_valid_partial_date($year, $month, $day);

    return $clean;
}

sub process_relationship {
    my ($c, $loader, $data, $previewing) = @_;

    $data->{entity0} = $data->{entities}->[0];
    $data->{entity1} = $data->{entities}->[1];

    trim_string($data, 'entity0_credit');
    trim_string($data, 'entity1_credit');

    my $begin_date = clean_partial_date(delete $data->{begin_date});
    my $end_date = clean_partial_date(delete $data->{end_date});
    my $ended = delete $data->{ended};

    if (!defined($begin_date) && $data->{relationship}) {
        $begin_date = partial_date_to_hash($data->{relationship}->link->begin_date);
    }

    if (!defined($end_date) && $data->{relationship}) {
        $end_date = partial_date_to_hash($data->{relationship}->link->end_date);
    }

    $data->{begin_date} = $begin_date;
    $data->{end_date} = $end_date;
    $data->{ended} = boolean_from_json($ended) if defined $ended;

    if (defined $data->{attributes}) {
        $data->{attributes} = merge_link_attributes(
            $data->{attributes},
            [$data->{relationship} ? $data->{relationship}->link->all_attributes : ()]
        );
    }

    delete $data->{id};
    delete $data->{linkTypeID};
    delete $data->{entities};
    delete $data->{linkOrder};

    for my $prop ('entity0', 'entity1') {
        my $entity_data = $data->{$prop};

        if ($entity_data) {
            my $name = $entity_data->{name};
            my $entity_type_prop = "${prop}_type";
            my $model = type_to_model($data->{link_type}->$entity_type_prop);

            if ($model eq 'URL') {
                my $url = URI->new($name)->canonical;

                my $url_string = $url->as_string;
                my $url_scheme = $url->scheme;

                die "invalid URL: $url_string" unless is_valid_url($url_string);
                die "unsupported URL protocol: $url_scheme" unless lc($url_scheme) =~ m/^(https?|ftp)$/;

                $name = $entity_data->{name} = $url_string;
            }

            if ($previewing && !$entity_data->{gid}) {
                my $entity_class = "MusicBrainz::Server::Entity::$model";
                my ($entity) = $model eq 'URL' ? $c->model('URL')->find_by_url($name) : ();

                $data->{$prop} = $entity // $entity_class->new(name => $name);
            } elsif ($model eq 'URL') {
                $data->{$prop} = $c->model('URL')->find_or_insert($name);
            } else {
                $loader->($entity_data->{gid}, $model, sub { $data->{$prop} = shift });
            }
        } elsif ($data->{relationship}) {
            $data->{$prop} = $data->{relationship}->$prop;
        }
    }
}

sub process_edits {
    my ($c, $edits, $previewing) = @_;

    my $ids_to_load = {};
    my $gids_to_load = {};
    my $relationships_to_load = {};
    my @link_types_to_load;
    my @props_to_load;
    my @loaded_relationships;
    my @non_existent_entities;
    my @relationship_edits;

    for my $edit (@$edits) {
        my $edit_type = $edit->{edit_type};

        if ($edit_type ~~ [$EDIT_RELATIONSHIP_CREATE, $EDIT_RELATIONSHIP_EDIT, $EDIT_RELATIONSHIP_DELETE]) {
            push @link_types_to_load, $edit->{linkTypeID};
            push @relationship_edits, $edit;
        }
    }

    my $link_types = $c->model('LinkType')->get_by_ids(@link_types_to_load);

    for my $edit (@relationship_edits) {
        my $link_type = $link_types->{$edit->{linkTypeID}};

        $c->forward('/ws/js/detach_with_error', ['unknown linkTypeID: ' . $edit->{linkTypeID}]) unless $link_type;

        $edit->{link_type} = $link_type;

        if ($edit->{edit_type} ~~ [$EDIT_RELATIONSHIP_EDIT, $EDIT_RELATIONSHIP_DELETE]) {
            my $id = $edit->{id} or $c->forward('/ws/js/detach_with_error', ['missing relationship id']);

            my $type0 = $link_type->entity0_type;
            my $type1 = $link_type->entity1_type;

            # Only one edit per relationship is supported.
            ($relationships_to_load->{"$type0-$type1"} //= {})->{$id} = $edit;
        }
    }

    while (my ($types, $edits) = each %$relationships_to_load) {
        my ($type0, $type1) = split /-/, $types;

        my $relationships_by_id = $c->model('Relationship')->get_by_ids(
           $type0, $type1, keys %$edits
        );

        while (my ($id, $edit) = each %$edits) {
            unless ($edit->{relationship} = $relationships_by_id->{$id}) {
                push @non_existent_entities, { type => 'relationship', id => $id };
            }
        }

        push @loaded_relationships, values %$relationships_by_id;
    }

    $c->model('Link')->load(@loaded_relationships);
    $c->model('LinkType')->load(map { $_->link } @loaded_relationships);
    $c->model('Relationship')->load_entities(@loaded_relationships);

    my $loader = sub {
        my ($id, $model, $setter) = @_;

        if (looks_like_number($id)) {
            push @{ $ids_to_load->{$model} //= [] }, $id;
        } elsif (is_guid($id)) {
            push @{ $gids_to_load->{$model} //= [] }, $id;
        } elsif (!defined($id) && $previewing) {
            return;
        } else {
            $c->forward('/ws/js/detach_with_error', ["unknown $model id: $id"]);
        }

        push @props_to_load, [$id, $model, $setter];
    };

    my @new_edits;
    my @attribute_gids;

    for my $edit (@$edits) {
        if ($edit->{edit_type} == $EDIT_RELATIONSHIP_CREATE) {
            push @attribute_gids, map { $_->{type}{gid} } @{ $edit->{attributes} // [] };
        }
    }

    my $attributes = $c->model('LinkAttributeType')->get_by_gids(@attribute_gids);

    for my $edit (@$edits) {
        if ($edit->{edit_type} == $EDIT_RELATIONSHIP_CREATE) {
            push @new_edits, split_relationship_by_attributes($attributes, $edit);
        } else {
            push @new_edits, $edit;
        }
    }

    try {
        for my $edit (@new_edits) {
            my $processor = $data_processors->{$edit->{edit_type}};
            $processor->($c, $loader, $edit, $previewing) if $processor;
        }
    } catch {
        MusicBrainz::Server::Controller::WS::js->critical_error($c, $_);
    };

    my %loaded_entities = (
        ( map { $_ => $c->model($_)->get_by_ids(@{ $ids_to_load->{$_} }) } keys %$ids_to_load ),
        ( map { $_ => $c->model($_)->get_by_gids(@{ $gids_to_load->{$_} }) } keys %$gids_to_load ),
    );

    for (@props_to_load) {
        my ($id, $model, $setter) = @$_;

        unless ($setter->($loaded_entities{$model}->{$id})) {
            push @non_existent_entities, {
                type => model_to_type($model),
                is_guid($id) ? ( gid => $id ) : ( id => $id ),
            };
        }
    }

    if (@non_existent_entities) {
        $c->forward('/ws/js/detach_with_error', [{
            errorCode => $ERROR_NON_EXISTENT_ENTITIES,
            entities => \@non_existent_entities
        }]);
    }

    return \@new_edits;
}

sub create_edits {
    my ($self, $c, $data, $previewing) = @_;

    my $privs = $c->user->privileges;

    if ($data->{makeVotable}) {
        $privs |= $UNTRUSTED_FLAG;
    }

    $data->{edits} = process_edits($c, $data->{edits}, $previewing);

    my $action = $previewing ? 'preview' : 'create';

    return map {
        my $opts = $_;
        my $edit;

        try {
            $edit = $c->model('Edit')->$action(
                %$opts,
                editor => $c->user,
                privileges => $privs,
            );
        } catch {
            if (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::Forbidden') {
                $c->forward('/ws/js/detach_with_error', ['editor is forbidden to enter this edit', 403]);
            } elsif (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges') {
                # The data submitted doesn't change anything. This happens
                # occasionally when stale search indexes are used as a source
                # for comparison. But, these exceptions shouldn't cause the
                # request to fail, so pass.
            } elsif (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::FailedDependency') {
                $c->forward('/ws/js/detach_with_error', ["$_"]);
            } else {
                MusicBrainz::Server::Controller::WS::js->critical_error($c, $_);
            }
        };
        $edit;
    } @{ $data->{edits} };
}

sub edit : Chained('/') PathPart('ws/js/edit') CaptureArgs(0) Edit {
    my ($self, $c) = @_;

    $c->res->content_type('application/json; charset=utf-8');

    if ($c->stash->{server_details}->{is_slave_db} || DBDefs->DB_READ_ONLY) {
        $c->forward('/ws/js/detach_with_error', ['this server is in read-only mode']);
    }

    $c->forward('/ws/js/check_login', [{
        errorCode => $ERROR_NOT_LOGGED_IN,
        message => l('You must be logged in to submit edits. {url|Log in} ' .
                     'first, and then try submitting your edits again.',
                     { url => { href => $c->uri_for_action('/user/login'), target => '_blank' } }),
    }]);

    unless ($c->user->has_confirmed_email_address) {
        $c->forward('/ws/js/detach_with_error', ['a verified email address is required']);
    }
    if ($c->user->is_editing_disabled) {
        $c->forward('/ws/js/detach_with_error', ['you are not allowed to enter edits']);
    }
}

sub create : Chained('edit') PathPart('create') Edit {
    my ($self, $c) = @_;

    $self->submit_edits($c, $c->forward('/ws/js/get_json_request_body'));
}

sub submit_edits {
    my ($self, $c, $data) = @_;

    for my $edit (@{ $data->{edits} // [] }) {
        my $edit_type = $edit->{edit_type};

        unless (defined $edit_type) {
            $c->forward('/ws/js/detach_with_error', ['edit_type required']);
        }

        if ($edit_type == $EDIT_RELEASE_CREATE && !$data->{editNote}) {
            $c->forward('/ws/js/detach_with_error', ['editNote required']);
        }

        unless ($edit_type ~~ $ALLOWED_EDIT_TYPES) {
            $c->forward('/ws/js/detach_with_error', ["edit_type $edit_type is not supported"]);
        }
    }

    my @edits;

    $c->model('MB')->with_transaction(sub {
        @edits = $self->create_edits($c, $data);

        my $edit_note = $data->{editNote};

        if ($edit_note) {
            for my $edit (grep { $_ } @edits) {
                $c->model('EditNote')->add_note($edit->id, {
                    text => $edit_note, editor_id => $c->user->id,
                });
            }
        }
    });

    my $created_entity_ids = {};
    my $created_entities = {};

    for my $edit (grep { defined $_ } @edits) {
        if ($edit->isa('MusicBrainz::Server::Edit::Generic::Create') &&
            !$edit->isa('MusicBrainz::Server::Edit::Relationship::Create')) {

            push @{ $created_entity_ids->{$edit->_create_model} //= [] }, $edit->entity_id;
        }
    }

    for my $model (keys %$created_entity_ids) {
        $created_entities->{$model} = $c->model($model)->get_by_ids(
            @{ $created_entity_ids->{$model} }
        );
    }

    my @response = map {
        my $edit = $_;
        my $response;

        if (defined $edit) {
            $response = { edit_type => $edit->edit_type, response => $WS_EDIT_RESPONSE_OK };

            if ($edit->isa('MusicBrainz::Server::Edit::Generic::Create') &&
                !$edit->isa('MusicBrainz::Server::Edit::Relationship::Create')) {

                my $model = $edit->_create_model;
                my $entity = $created_entities->{$model}->{$edit->entity_id};

                try {
                    $response->{entity} = JSONSerializer->serialize_internal($c, $entity);
                } catch {
                    # Some entities (i.e. Mediums) don't have a WS::js model
                    # or serialization method. Just return their id.
                    $response->{entity} = { id => $entity->id };

                    if ($model eq 'Medium') {
                        $response->{entity}->{position} = $entity->position;
                    }
                };
            } elsif ($edit->isa('MusicBrainz::Server::Edit::Release::AddReleaseLabel')) {
                $response->{entity} = {
                    id              => $edit->entity_id,
                    labelID         => defined($edit->data->{label}) ? $edit->data->{label}{id} : undef,
                    catalogNumber   => $edit->data->{catalog_number} // undef,
                };
            }
        } else {
            $response = { response => $WS_EDIT_RESPONSE_NO_CHANGES };
        }

        $response
    } @edits;

    $c->res->body(encode_json({ edits => \@response }));
}

sub preview : Chained('edit') PathPart('preview') Edit {
    my ($self, $c) = @_;

    my $data = $c->forward('/ws/js/get_json_request_body');

    my @edits = grep { $_ } $self->create_edits($c, $data, 1);

    $c->model('Edit')->load_all(@edits);

    MusicBrainz::Server::View::Base->process($c);

    my @previews = map {
        my $edit = $_;

        my $edit_template_react = $edit->edit_template_react;
        my $preview;

        if ($edit_template_react) {
            my $response = render_component(
                $c,
                "edit/details/$edit_template_react",
                {edit => to_json_object($edit), allowNew => \1},
            );
            my $body = $response->{body} // '';
            my $content_type = $response->{content_type} // '';
            $preview = $content_type eq 'text/html'
                ? $body
                : encode_entities($body);
        } else {
            my $edit_template = $edit->edit_template;
            my $out = '';

            $preview = $TT->process(
                "edit/details/${edit_template}.tt",
                {edit => $edit, c => $c, allow_new => 1},
                \$out,
                binmode => 1,
            ) ? $out : '' . $TT->error();
        }

        { preview => $preview, editName => $edit->l_edit_name };
    } @edits;

    MusicBrainz::Server::View::Base->_post_process($c);

    $c->res->body(encode_json({ previews => \@previews }));
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
