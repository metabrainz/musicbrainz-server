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
    $AUTO_EDITOR_FLAG
);
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
};


our $data_processors = {

    $EDIT_MEDIUM_CREATE => sub { process_medium(@_) },

    $EDIT_MEDIUM_EDIT => sub { process_medium(@_) },
};


sub process_medium {
    my ($c, $data) = @_;

    return unless defined $data->{tracklist};

    my @tracks = @{ $data->{tracklist} };
    my @recording_gids = grep { $_ } map { $_->{recording_gid} } @tracks;
    my $recordings = $c->model('Recording')->get_by_gids(@recording_gids);

    my $process_track = sub {
        my $track = shift;
        my $recording_gid = delete $track->{recording_gid};

        if (defined $recording_gid) {
            $track->{recording} = $recordings->{$recording_gid};
            $track->{recording_id} = $recordings->{$recording_gid}->id;
        }

        delete $track->{id} unless defined $track->{id};

        my $ac = $track->{artist_credit};
        $track->{artist_credit} = process_artist_credit($c, $ac) if $ac;

        return Track->new(%$track);
    };

    $data->{tracklist} = [ map { $process_track->($_) } @tracks ];
}

sub process_artist_credit {
    my ($c, $data) = @_;

    my @names = @{ $data->{names} };

    for my $name (@names) {
        my $artist = $name->{artist};
        my $gid = delete $artist->{gid};

        if ($gid && !$artist->{id}) {
            $artist->{id} = $c->model('Artist')->get_by_gid($gid)->id;
        }
    }

    return ArtistCredit->from_array(\@names);
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
    my ($c, $data) = @_;

    my $models = $entities_to_load->{$data->{edit_type}};
    return unless $models;

    for my $arg (keys %$models) {
        if (my $id = $data->{$arg}) {
            my $model = $models->{$arg};
            my $entity;

            $entity = $c->model($model)->get_by_id($id) if looks_like_number($id);
            $entity = $c->model($model)->get_by_gid($id) if is_guid($id);

            detach_with_error("%s=%s doesn't exist" % ($model, $id)) unless $entity;

            $data->{$arg} = $entity;
        }
    }
}

sub process_data {
    my ($c, $data) = @_;

    my $processor = $data_processors->{$data->{edit_type}};
    $processor->($c, $data) if $processor;
}

sub create_edits {
    my ($self, $c, $create, $data) = @_;

    my $privs = $c->user->privileges;

    if ($c->user->is_auto_editor && !$data->{as_auto_editor}) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    return map {
        my %opts = %$_;
        my $edit;

        try {
            load_entities($c, \%opts);
            process_data($c, \%opts);

            $edit = $create->(
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

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0) {}

sub edit : Chained('root') PathPart('edit') CaptureArgs(0) {
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

    $c->model('MB')->context->sql->begin;

    my @edits = $self->create_edits(
        $c, sub { $c->model('Edit')->create(@_) }, $data
    );

    my $edit_note = $data->{edit_note};

    if ($edit_note) {
        for my $edit (grep { $_ } @edits) {
            $c->model('EditNote')->add_note($edit->id, {
                text => $edit_note, editor_id => $c->user->id,
            });
        }
    }

    $c->model('MB')->context->sql->commit;

    my @response = map {
        my $edit = $_;
        my $response;

        if (defined $edit) {
            $response = { message => "OK" };

            if ($edit->isa('MusicBrainz::Server::Edit::Generic::Create')) {
                my $model = $edit->_create_model;
                my $entity = $c->model($model)->get_by_id($edit->entity_id);

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

    my @edits = grep { $_ } $self->create_edits(
        $c, sub { $c->model('Edit')->preview(@_) }, $data
    );

    $c->model('Edit')->load_all(@edits);

    # Make the edit preview templates not show entity [removed] crap
    $c->stash->{allow_new} = 1;

    my @previews = map {
        my $edit = $_;

        my $edit_template = $edit->edit_template;
        my $vars = { edit => $edit, c => $c };
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
