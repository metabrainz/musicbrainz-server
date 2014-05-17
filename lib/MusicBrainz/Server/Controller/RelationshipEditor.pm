package MusicBrainz::Server::Controller::RelationshipEditor;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Encode;
use JSON qw( encode_json );
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
);
use Try::Tiny;

with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

__PACKAGE__->config( namespace => 'relationship_editor' );

our $valid_params = qr/
    ^rel-editor\.(
        rels\.[0-9]+\.(
            action
            |id
            |link_type
            |entity\.(0|1)\.(gid|type|url)
            |period\.(begin_date|end_date)\.(year|month|day)
            |ended
            |attrs\.[^\.](\.[0-9]+)?
        )
        |edit_note
        |as_auto_editor
    )$
/x;

sub base : Path('/relationship-editor') Args(0) Edit {
    my ($self, $c) = @_;

    $c->res->content_type('application/json; charset=utf-8');

    if ($c->form_posted) {
        my $params = $c->req->body_parameters;

        try {
            for my $key (keys %$params) {
                if ($key !~ $valid_params) {
                    die "Unknown parameter: “$key”";
                } elsif (ref($params->{$key}) eq 'ARRAY') {
                    # remove duplicate params
                    $params->{$key} = $params->{$key}->[0];
                }
            }
        } catch {
            $c->res->status(400);
            $c->res->body(encode_json({ error => $_ }));
        };

        $params = expand_hash($params);
        $self->submit_edits($c, $params->{'rel-editor'});
    } else {
        $c->res->status(400);
        $c->res->body(encode_json({ error => 'Invalid submission' }));
    }
}

sub submit_edits {
    my ($self, $c, $params) = @_;

    my $attr_tree = $c->model('LinkAttributeType')->get_tree;

    foreach my $rel (@{ $params->{rels} // [] }) {
        for my $i (0, 1) {
            my $entity = $rel->{entity}->[$i];

            $entity->{entityType} = delete $entity->{type} or die "Missing field: entity.$i.type";

            if (my $url = delete $entity->{url}) {
                $entity->{name} = $url;
            }
        }

        $rel->{entities} = delete $rel->{entity};
        $rel->{linkTypeID} = delete $rel->{link_type};

        if (my $attrs = delete $rel->{attrs}) {
            my @flattend;

            for my $root ($attr_tree->all_children) {
                my $value = $attrs->{$root->name};
                next unless defined($value);

                push @flattend, scalar($root->all_children)
                    ? @$value : $value ? $root->id : ();
            }

            $rel->{attributes} = \@flattend;
        }

        if (my $period = delete $rel->{period}) {
            $rel->{beginDate} = $period->{begin_date} if $period->{begin_date};
            $rel->{endDate} = $period->{end_date} if $period->{end_date};
            $rel->{ended} = $period->{ended} if $period->{ended};
        }

        my $action = delete $rel->{action};

        if ($action eq 'remove') {
            $rel->{edit_type} = $EDIT_RELATIONSHIP_DELETE;
        } elsif ($action eq 'add') {
            $rel->{edit_type} = $EDIT_RELATIONSHIP_CREATE;
        } elsif ($action eq 'edit') {
            $rel->{edit_type} = $EDIT_RELATIONSHIP_EDIT;
        } else {
            die "Missing field: action";
        }
    }

    MusicBrainz::Server::Controller::WS::js::Edit->submit_edits($c, {
        edits => $params->{rels},
        asAutoEditor => $params->{as_auto_editor},
        editNote => $params->{edit_note},
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
