package MusicBrainz::Server::Controller::WS::1;

use strict;
use warnings;

use MusicBrainz::Server::Handlers::WS::1::Artist;
use MusicBrainz::Server::Handlers::WS::1::Common;
use MusicBrainz::Server::Handlers::WS::1::Release;
use MusicBrainz::Server::Handlers::WS::1::Label;
use MusicBrainz::Server::Handlers::WS::1::Track;
use MusicBrainz::Server::Handlers::WS::1::Rating;
use MusicBrainz::Server::Handlers::WS::1::Collection;
use MusicBrainz::Server::Handlers::WS::1::Tag;
use MusicBrainz::Server::Handlers::WS::1::User;

use base 'MusicBrainz::Server::Controller';

=head1 NAME

MusicBrainz::Server::Controller::WS::1 - version 1 of the MusicBrainz XML web service

=head1 DESCRIPTION

Handles dispatching calls to the existing Web Service perl modules. TT is not being used for this service.

=head1 METHODS

=head2 artist

Handle artist related web service queries

=cut


sub artist : Path('artist') :Minimal
{
    my ($self, $c) = @_;

    my ($info, $bad) = parse_inc($c->req->params->{inc} || '');
    return bad_req($c, "Invalid inc options: '$bad'.") if ($bad);
    return bad_req($c, "HEAD not supported yet") if ($c->req->method eq "HEAD");

    # Artist, Label, Release & Track in GET mode don't require authentication
    # unless user data (tags, ratings) are requested
    if ($c->req->method eq "GET" && (($info->{inc} & INC_USER_TAGS) || ($info->{inc} & INC_USER_RATINGS)))
    {
        $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    }
    MusicBrainz::Server::Handlers::WS::1::Artist::handler($c, $info);
}

=head2 release

Handle release related web service queries

=cut

sub release : Path('release') :Minimal
{
    my ($self, $c) = @_;

    my ($info, $bad) = parse_inc($c->req->params->{inc} || '');
    return bad_req($c, "Invalid inc options: '$bad'.") if ($bad);
    return bad_req($c, "HEAD not supported yet") if ($c->req->method eq "HEAD");

    # Artist, Label, Release & Track in GET mode don't require authentication
    # unless user data (tags, ratings) are requested
    if ($c->req->method eq "GET" && (($info->{inc} & INC_USER_TAGS) || ($info->{inc} & INC_USER_RATINGS)))
    {
        $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    }
    MusicBrainz::Server::Handlers::WS::1::Release::handler($c, $info);
}

=head2 track

Handle track related web service queries

=cut

sub track : Path('track') :Minimal
{
    my ($self, $c) = @_;

    my ($info, $bad) = parse_inc($c->req->params->{inc} || '');
    return bad_req($c, "Invalid inc options: '$bad'.") if ($bad);
    return bad_req($c, "HEAD not supported yet") if ($c->req->method eq "HEAD");

    # Artist, Label, Release & Track in GET mode don't require authentication
    # unless user data (tags, ratings) are requested
    if ($c->req->method eq "GET" && (($info->{inc} & INC_USER_TAGS) || ($info->{inc} & INC_USER_RATINGS)))
    {
        $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    }
    MusicBrainz::Server::Handlers::WS::1::Track::handler($c, $info);
}

=head2 label

Handle label related web service queries

=cut

sub label : Path('label') :Minimal
{
    my ($self, $c) = @_;

    my ($info, $bad) = parse_inc($c->req->params->{inc} || '');
    return bad_req($c, "Invalid inc options: '$bad'.") if ($bad);
    return bad_req($c, "HEAD not supported yet") if ($c->req->method eq "HEAD");

    # Artist, Label, Release & Track in GET mode don't require authentication
    # unless user data (tags, ratings) are requested
    if ($c->req->method eq "GET" && (($info->{inc} & INC_USER_TAGS) || ($info->{inc} & INC_USER_RATINGS)))
    {
        $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    }
    MusicBrainz::Server::Handlers::WS::1::Label::handler($c, $info);
}

=head2 tag

Handle tag related web service queries

=cut

sub tag : Path('tag') :Minimal
{
    my ($self, $c) = @_;

    if ($c->req->method eq "POST")
    {
        $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    }
    MusicBrainz::Server::Handlers::WS::1::Tag::handler($c);
}

=head2 user

Handle user related web service queries

=cut

sub user : Path('user') :Minimal
{
    my ($self, $c) = @_;
    $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    MusicBrainz::Server::Handlers::WS::1::User::handler($c);
}

=head2 rating

Handle rating related web service queries

=cut

sub rating : Path('rating') :Minimal
{
    my ($self, $c) = @_;

    $c->authenticate({ realm => 'musicbrainz.org'}, "musicbrainz.org");
    MusicBrainz::Server::Handlers::WS::1::Rating::handler($c);
}

=head2 collection

Handle collection related web service queries

=cut

sub collection : Path('collection') :Minimal
{
    my ($self, $c) = @_;
    $c->authenticate({}, "musicbrainz.org");
    MusicBrainz::Server::Handlers::WS::1::Collection::handler($c);
}

1;
