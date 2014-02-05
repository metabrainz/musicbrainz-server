package MusicBrainz::Server::Controller::WS::js::Edit;
use DBDefs;
use File::Spec::Functions qw( catdir );
use JSON::Any;
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
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_EDIT
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_RECORDING_EDIT
    $EDIT_RELEASE_REORDER_MEDIUMS
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
    $AUTO_EDITOR_FLAG
);
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Validation qw( is_guid );
use Scalar::Util qw( looks_like_number );
use Try::Tiny;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::WebService::JSONSerializer';
BEGIN { extends 'MusicBrainz::Server::Controller' }


our $TT = Template->new(
    INCLUDE_PATH => catdir(DBDefs->MB_SERVER_ROOT, 'root'),

    %{ MusicBrainz::Server->config->{'View::Default'} }
);

our $JSON = JSON::Any->new( utf8 => 0 );


our $entities_to_load = {

    $EDIT_RELEASE_EDIT => { to_edit => 'Release' },

    $EDIT_RELEASE_ADDRELEASELABEL => { release => 'Release', label => 'Label' },

    $EDIT_RELEASE_ADD_ANNOTATION => { entity => 'Release' },

    $EDIT_RELEASE_DELETERELEASELABEL => { release_label => 'ReleaseLabel' },

    $EDIT_RELEASE_EDITRELEASELABEL => { release_label => 'ReleaseLabel', label => 'Label' },

    $EDIT_MEDIUM_CREATE => { release => 'Release' },

    $EDIT_MEDIUM_EDIT => { to_edit => 'Medium' },

    $EDIT_MEDIUM_DELETE => { medium => 'Medium' },

    $EDIT_MEDIUM_ADD_DISCID => { release => 'Release' },

    $EDIT_RECORDING_EDIT => { to_edit => 'Recording' },

    $EDIT_RELEASE_REORDER_MEDIUMS => { release => 'Release' },

    $EDIT_RELATIONSHIP_CREATE => { link_type => 'LinkType' },

    $EDIT_RELATIONSHIP_EDIT => { link_type => 'LinkType' },
};


our $data_processors = {

    $EDIT_MEDIUM_CREATE => sub { process_medium(@_) },

    $EDIT_MEDIUM_EDIT => sub { process_medium(@_) },

    $EDIT_RELATIONSHIP_CREATE => sub { process_relationship(@_) },

    $EDIT_RELATIONSHIP_EDIT => sub { process_relationship(@_) },
};


sub process_medium {
    my ($c, $data) = @_;

    return unless defined $data->{tracklist};

    my @tracks = @{ $data->{tracklist} };
    my @recording_gids = grep { $_ } map { $_->{recording_gid} } @tracks;
    my $recordings = $c->model('Recording')->get_by_gids(@recording_gids);

    my @artist_gids;

    for my $track (@tracks) {
        my $ac = $track->{artist_credit};

        if ($ac) {
            my @names = @{ $ac->{names} };

            for my $name (@names) {
                my $artist = $name->{artist};
                push @artist_gids, $artist->{gid} if $artist->{gid};
            }
        }
    }

    my $artists = $c->model('Artist')->get_by_gids(@artist_gids);

    my $process_track = sub {
        my $track = shift;
        my $recording_gid = delete $track->{recording_gid};

        if (defined $recording_gid) {
            $track->{recording} = $recordings->{$recording_gid};
            $track->{recording_id} = $recordings->{$recording_gid}->id;
        }

        delete $track->{id} unless defined $track->{id};

        my $ac = $track->{artist_credit};

        if ($ac) {
            my @names = @{ $ac->{names} };

            for my $name (@names) {
                my $artist = $name->{artist};
                my $gid = delete $artist->{gid};

                $artist->{id} = $artists->{$gid}->id if $gid;
            }

            $track->{artist_credit} = ArtistCredit->from_array(\@names);
        }

        return Track->new(%$track);
    };

    $data->{tracklist} = [ map { $process_track->($_) } @tracks ];
}

sub process_relationship {
    my ($c, $data) = @_;

    $data->{ended} //= 0;
}

sub detach_with_error {
    my ($c, $error) = @_;

    $c->res->body($JSON->encode({ error => $error }));
    $c->res->status(400);
    $c->detach;
}

sub get_request_body {
    my $c = shift;

    my $body = $c->req->body;

    detach_with_error($c, 'empty request') unless $body;

    my $json_string = <$body>;
    my $decoded_object = eval { $JSON->decode($json_string) };

    detach_with_error($c, "$@") if $@;

    return $decoded_object;
}

sub load_entities {
    my ($c, $edits, $previewing) = @_;

    my $ids_to_load = {};
    my $gids_to_load = {};

    for my $edit (@$edits) {
        my $edit_type = $edit->{edit_type};

        if ($edit_type == $EDIT_RELATIONSHIP_CREATE || $edit_type == $EDIT_RELATIONSHIP_EDIT) {
            for my $i (0, 1) {
                delete $entities_to_load->{$edit_type}->{"entity$i"};

                my $model = type_to_model($edit->{"type$i"});
                my $entity_class = "MusicBrainz::Server::Entity::$model";

                if ($model eq 'URL') {
                    my $url_string = $edit->{"entity$i"};

                    if ($previewing) {
                        my ($entity) = $c->model('URL')->find_by_url($url_string);

                        $edit->{"entity$i"} = $entity || $entity_class->new( url => $url_string );
                    }
                    else {
                        $edit->{"entity$i"} = $c->model('URL')->find_or_insert($url_string);
                    }
                }
                else {
                    if ($previewing and my $preview = delete $edit->{"entity${i}Preview"}) {
                        $edit->{"entity$i"} = $entity_class->new( name => $preview );
                    }
                    else {
                        $entities_to_load->{$edit_type}->{"entity$i"} = $model;
                    }
                }
            }
        }

        if ($edit_type == $EDIT_RELATIONSHIP_EDIT || $edit_type == $EDIT_RELATIONSHIP_DELETE) {
            $edit->{relationship} = $c->model('Relationship')->get_by_id(
               $edit->{type0}, $edit->{type1}, $edit->{relationship}
            );
            $c->model('Link')->load($edit->{relationship});
            $c->model('LinkType')->load($edit->{relationship}->link);
        }

        my $models = $entities_to_load->{$edit_type};
        next unless $models;

        for my $arg (keys %$models) {
            if (my $id = $edit->{$arg}) {
                my $model = $models->{$arg};

                push @{ $ids_to_load->{$model} //= [] }, $id if looks_like_number($id);
                push @{ $gids_to_load->{$model} //= [] }, $id if is_guid($id);
            }
        }
    }

    my %loaded_ids = map {
        $_ => $c->model($_)->get_by_ids(@{ $ids_to_load->{$_} })
    } keys %$ids_to_load;

    my %loaded_gids = map {
        $_ => $c->model($_)->get_by_gids(@{ $gids_to_load->{$_} })
    } keys %$gids_to_load;

    for my $edit (@$edits) {
        my $models = $entities_to_load->{$edit->{edit_type}};
        next unless $models;

        for my $arg (keys %$models) {
            if (my $id = $edit->{$arg}) {
                my $model = $models->{$arg};
                my $entity;

                $entity = $loaded_ids{$model}->{$id} if looks_like_number($id);
                $entity = $loaded_gids{$model}->{$id} if is_guid($id);

                detach_with_error($c, sprintf("%s=%s doesn't exist", $model, $id)) unless $entity;

                $edit->{$arg} = $entity;
            }
        }
    }
}

sub process_data {
    my ($c, $data) = @_;

    my $processor = $data_processors->{$data->{edit_type}};
    $processor->($c, $data) if $processor;
}

sub create_edits {
    my ($self, $c, $data, $previewing) = @_;

    my $privs = $c->user->privileges;

    if ($c->user->is_auto_editor && !$data->{as_auto_editor}) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    try {
        load_entities($c, $data->{edits}, $previewing);
    }
    catch {
        detach_with_error($c, "$_");
    };

    return map {
        my %opts = %$_;
        my $edit;
        my $action = $previewing ? 'preview' : 'create';

        try {
            process_data($c, \%opts);

            $edit = $c->model('Edit')->$action(
                editor_id => $c->user->id,
                privileges => $privs,
                %opts
            );
        }
        catch {
            unless(ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges') {
                detach_with_error($c, "$_");
            }
        };
        $edit;
    } @{ $data->{edits} };
}

sub edit : Chained('/') PathPart('ws/js/edit') CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->res->content_type('application/json; charset=utf-8');
    detach_with_error($c, 'not logged in') unless $c->user;
}

sub create : Chained('edit') PathPart('create') {
    my ($self, $c) = @_;

    my $data = get_request_body($c);

    my @edit_data = @{ $data->{edits} };
    my @edit_types = map { $_->{edit_type} } @edit_data;

    if (any { !defined($_) } @edit_types) {
        detach_with_error($c, 'edit_type required');
    }

    if (!$data->{edit_note} && any { $_ == $EDIT_RELEASE_CREATE } @edit_types) {
        detach_with_error($c, 'edit_note required');
    }

    my @edits;

    $c->model('MB')->with_transaction(sub {
        @edits = $self->create_edits($c, $data);

        my $edit_note = $data->{edit_note};

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
            $response = { message => "OK" };

            if ($edit->isa('MusicBrainz::Server::Edit::Generic::Create') &&
                !$edit->isa('MusicBrainz::Server::Edit::Relationship::Create')) {

                my $model = $edit->_create_model;
                my $entity = $created_entities->{$model}->{$edit->entity_id};

                try {
                    my $js_model = "MusicBrainz::Server::Controller::WS::js::$model";
                    my $serialization_routine = $js_model->serialization_routine;

                    $js_model->_load_entities($c, $entity);

                    $response->{entity} = JSONSerializer->$serialization_routine($entity);
                    $response->{entity}->{type} = $js_model->type;
                }
                catch {
                    # Some entities (i.e. Mediums) don't have a WS::js model
                    # or serialization_routine. Just return their id.
                    $response->{entity} = { id => $entity->id };

                    if ($model eq 'Medium') {
                        $response->{entity}->{position} = $entity->position;
                    }
                };
            }
        } else {
            $response = { message => "no changes" };
        }

        $response
    } @edits;

    $c->res->body($JSON->encode({ edits => \@response }));
}

sub preview : Chained('edit') PathPart('preview') {
    my ($self, $c) = @_;

    my $data = get_request_body($c);

    my @edits = grep { $_ } $self->create_edits($c, $data, 1);

    $c->model('Edit')->load_all(@edits);

    my @previews = map {
        my $edit = $_;

        my $edit_template = $edit->edit_template;
        my $vars = { edit => $edit, c => $c, allow_new => 1 };
        my $out = '';

        my $preview = $TT->process("edit/details/${edit_template}.tt", $vars, \$out)
            ? $out : '' . $TT->error();

        { preview => $preview, editName => $edit->edit_name };
    } @edits;

    $c->res->body($JSON->encode({ previews => \@previews }));
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
