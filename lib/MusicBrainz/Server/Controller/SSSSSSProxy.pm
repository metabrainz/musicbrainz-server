package MusicBrainz::Server::Controller::SSSSSSProxy;
use strict;
use warnings;

use HTTP::Request;
use LWP::UserAgent;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use URI;

use DBDefs;

extends 'Catalyst::Controller';

__PACKAGE__->config( namespace => 'ssssss' );

sub _get_content : Private {
    my ($self, $c) = @_;
    my %content = %{ $c->req->body_parameters };
    for my $upload_key (keys %{ $c->req->uploads }) {
        my $upload = $c->req->uploads->{$upload_key};
        $content{$upload_key} = [
            $upload->tempname,
            $upload->filename,
            'Content-Type' => $upload->type,
        ];
    }
    return %content;
}

sub ssssss : Path('/ssssss') {
    my ($self, $c) = @_;

    unless (DBDefs->DB_STAGING_TESTING_FEATURES) {
        $c->res->status(403);
        $c->res->body('');
        $c->detach;
    }

    my $proxy_uri = URI->new(DBDefs->SSSSSS_SERVER);
    $proxy_uri->path_query(
        $c->req->uri->path_query =~ s{^/ssssss}{}r,
    );

    my $req_headers = $c->req->headers->clone;
    $req_headers->remove_header('Content-Length');

    my $lwp = LWP::UserAgent->new;
    my $method = lc $c->req->method;
    my $proxy_res;

    if ($method eq 'options') {
        $proxy_res = $lwp->get(HTTP::Request->new(
            'OPTIONS',
            $proxy_uri,
            $req_headers,
        ));
    } elsif ($method eq 'delete' || $method eq 'get') {
        $proxy_res = $lwp->$method($proxy_uri, $req_headers->flatten);
    } elsif ($method eq 'post' || $method eq 'put') {
        my %content = $self->_get_content($c);
        if (%content) {
            $req_headers->header('Content-Type', 'form-data');
        }
        $proxy_res = $lwp->$method(
            $proxy_uri,
            $req_headers->flatten,
            %content ? (Content => \%content) : (),
        );
    }

    $c->res->status($proxy_res->code);
    $c->res->headers($proxy_res->headers->clone);
    $c->res->body($proxy_res->content);
}

1;

=pod

=head1 NAME

MusicBrainz::Server::Controller::SSSSSSProxy - proxy for contrib/ssssss.psgi

=head1 DESCRIPTION

This endpoint acts as a proxy between the client's browser and
contrib/ssssss.psgi. It's generally only useful in pseudo-production
environments, like test.musicbrainz.org, where it negates the need to expose
ssssss over a public gateway.

It's expected that `SSSSSS_SERVER` points to the internal host and port which
ssssss.psgi is listening on; and that `INTERNET_ARCHIVE_UPLOAD_PREFIXER`
points to `SSSSSS_SERVER` as follows:

    sub INTERNET_ARCHIVE_UPLOAD_PREFIXER {
        my ($self, $bucket) = @_;
        return $self->SSSSSS_SERVER . "/$bucket";
    }

The endpoint is disabled unless `DB_STAGING_TESTING_FEATURES` is on.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
