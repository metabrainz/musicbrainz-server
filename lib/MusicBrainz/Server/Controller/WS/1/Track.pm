package MusicBrainz::Server::Controller::WS::1::Track;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_ADD_ISRCS
    $ACCESS_SCOPE_SUBMIT_ISRC
);
use MusicBrainz::Server::Validation qw( is_valid_isrc is_guid );
use List::Util qw( first );
use Try::Tiny;
use aliased 'MusicBrainz::Server::Buffer';

__PACKAGE__->config(
    model => 'Recording',
);

my $ws_defs = Data::OptList::mkopt([
    track => {
        method   => 'GET',
        inc      => [ qw( artist tags isrcs puids releases _relations ratings user-ratings user-tags  ) ],
    },
    track => {
        method => 'POST',
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::ArtistCredit';
with 'MusicBrainz::Server::Controller::WS::1::Role::Rating';
with 'MusicBrainz::Server::Controller::WS::1::Role::Tags';
with 'MusicBrainz::Server::Controller::WS::1::Role::Relationships';

sub root : Chained('/') PathPart('ws/1/track') CaptureArgs(0) { }

around 'search' => sub
{
    my $orig = shift;
    my ($self, $c) = @_;

    $c->detach('submit') if $c->req->method eq 'POST';

    if (my $puid = $c->req->query_params->{puid}) {
        $self->bad_req($c, 'Invalid argument "puid": not a valid PUID')
            unless is_guid($puid);
    }

    if (exists $c->req->query_params->{puid}) {
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body(
            $c->stash->{serializer}->xml('')
        );
        $c->detach;
    }
    else {
        $self->$orig($c);
    }
};

sub submit : Private
{
    my ($self, $c) = @_;

    my (@isrcs);

    if (my $submitted = $c->req->params->{isrc}) {
        @isrcs = ref($submitted) ? @$submitted : ($submitted);
    }

    my $scope = 0;
    $scope |= $ACCESS_SCOPE_SUBMIT_ISRC if @isrcs;
    $self->authenticate($c, $scope);

    if (DBDefs->REPLICATION_TYPE == DBDefs->RT_SLAVE) {
        $c->stash->{error} = 'Cannot submit ISRCs to a slave server.';
        $c->detach('bad_req');
    }

    my @pairs = @isrcs;

    my %submit;
    for my $pair (@pairs) {
        my ($recording_id, $gid) = split(' ', $pair);

        unless (is_guid($recording_id)) {
            $c->stash->{error} = 'Recording IDs be valid MBIDs';
            $c->detach('bad_req');
        }

        $submit{$recording_id} ||= [];
        push @{ $submit{$recording_id} }, $gid;
    }

    # We have to have a limit, I think.  It's only sensible.
    # So far I've not seen anyone submit more that about 4,500 at once,
    # so this limit won't affect anyone in a hurry.
    if (scalar(map { @$_ } values %submit) > 5000) {
        $c->detach('declined');
    }

    # Create a mapping of GID to ID
    my %recordings = map
        { ($_->gid => $_) }
            values %{ $c->model('Recording')->get_by_gids(keys %submit) };

    $self->submit_isrc($c, \%submit, \%recordings) if @isrcs;

    $c->stash->{error} = 'You must specify a ISRC to submit';
    $c->detach('bad_req');
}

sub submit_isrc : Private
{
    my ($self, $c, $submit, $recordings) = @_;

    for my $isrcs (values %$submit) {
        for my $isrc (@$isrcs) {
            unless (is_valid_isrc($isrc)) {
                $c->stash->{error} = 'ISRCs must be in valid ISRC format';
                $c->detach('bad_req');
            }
        }
    }

    my $buffer = Buffer->new(
        limit   => 100,
        on_full => sub {
            my $contents = shift;
            try {
                $c->model('Edit')->create(
                    edit_type      => $EDIT_RECORDING_ADD_ISRCS,
                    editor_id      => $c->user->id,
                    isrcs          => $contents
                );
            }
            catch {
                my $err = $_;
                unless (blessed($err) && $err->isa('MusicBrainz::Server::Edit::Exceptions::NoChanges')) {
                    # Ignore the NoChanges exception
                    die $err;
                }
            };
        }
    );

    $c->model('MB')->with_transaction(sub {
        $buffer->flush_on_complete(sub {
            while (my ($recording_gid, $isrcs) = each %$submit) {
                next unless exists $recordings->{ $recording_gid };
                $buffer->add_items(map +{
                    recording => {
                        id   => $recordings->{ $recording_gid }->id,
                        name => $recordings->{ $recording_gid }->name
                    },
                    isrc         => $_
                }, @$isrcs);
            }
        });
    });

    $c->detach;
}

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;
    my $track = $c->stash->{entity};

    if ($c->stash->{inc}->isrcs) {
        $c->model('ISRC')->load_for_recordings($track);
    }

    if ($c->stash->{inc}->releases) {
        my @releases = $c->model('Release')->find_by_recording([ $track->id ]);
        my %releases = map { $_->id => $_ } @releases;

        $c->model('ReleaseStatus')->load(@releases);
        $c->model('ReleaseGroup')->load(@releases);
        $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
        $c->model('Script')->load(@releases);
        $c->model('Language')->load(@releases);

        $c->stash->{data}{releases} = \%releases;
        $c->stash->{data}{track_map} =
            $c->model('Recording')->find_tracklist_offsets($track->id);

        unless ($c->stash->{inc}->artist) {
            $c->model('ArtistCredit')->load($track);
            $c->model('Artist')->load($track->artist_credit->all_names);
        }
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('track', $track, $c->stash->{inc}, $c->stash->{data}));
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
