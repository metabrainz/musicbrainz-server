package MusicBrainz::Server::Controller::RelationshipEditor;

use utf8;

use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Encode;
use JSON;
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_DELETE
);
use MusicBrainz::Server::Data::Utils qw( non_empty );
use Try::Tiny;

__PACKAGE__->config( namespace => 'relationship_editor' );

our $valid_params = qr/
    ^rel-editor\.(
        rels\.[0-9]+\.(
            action
            |id
            |link_type
            |entity\.(0|1)\.(gid|type|url)
            |period\.((begin_date|end_date)\.(year|month|day)|ended)
            |attributes\.[0-9]+\.(type\.gid|text_value|credited_as|removed)
        )
        |edit_note
        |make_votable
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
            detach_with_error($c, $_);
        };

        $params = expand_hash($params);
        $self->submit_edits($c, $params->{'rel-editor'} // {});
    } else {
        detach_with_error($c, 'Invalid submission');
    }
}

sub submit_edits {
    my ($self, $c, $params) = @_;

    my @rels = @{ $params->{rels} // [] };

    foreach my $rel (@rels) {
        for my $i (0, 1) {
            my $entity = $rel->{entity}->[$i];

            if (my $url = delete $entity->{url}) {
                $entity->{name} = $url;
            }
        }

        $rel->{entities} = delete $rel->{entity};
        $rel->{linkTypeID} = delete $rel->{link_type};

        if (my $period = delete $rel->{period}) {
            $rel->{begin_date} = $period->{begin_date} if $period->{begin_date};
            $rel->{end_date} = $period->{end_date} if $period->{end_date};
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
            detach_with_error($c, 'Missing field: action');
        }
    }

    MusicBrainz::Server::Controller::WS::js::Edit->submit_edits($c, {
        edits => \@rels,
        makeVotable => $params->{make_votable},
        editNote => $params->{edit_note},
    });
}

sub detach_with_error {
    my ($c, $error) = @_;

    my $json = JSON->new;
    $c->res->body($json->encode({ error => $error }));
    $c->res->status(400);
    $c->detach;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
