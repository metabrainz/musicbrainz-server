package MusicBrainz::Server::Controller::WS::1::Label;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

__PACKAGE__->config(
    model => 'Label',
);

my $ws_defs = Data::OptList::mkopt([
    label => {
        method   => 'GET',
        inc      => [ qw( aliases _relations tags ratings user-tags user-ratings ) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::Alias';
with 'MusicBrainz::Server::Controller::WS::1::Role::Rating';
with 'MusicBrainz::Server::Controller::WS::1::Role::Tags';

sub root : Chained('/') PathPart('ws/1/label') CaptureArgs(0) { }

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;
    my $label = $c->stash->{entity};

    if ($c->stash->{inc}->has_rels)
    {
        my $types = $c->stash->{inc}->get_rel_types();
        my @rels = $c->model('Relationship')->load_subset($types, $label);
        $c->stash->{data}->{rels} = $label->relationships;

        # load the artist type, as /ws/1 always included that for artists.
        my @artists = grep { $_->target_type eq 'artist' } @{$c->stash->{data}->{rels}};
        $c->model('ArtistType')->load(map { $_->target } @artists);

        # load the label country and type, as /ws/1 always included that for labels.
        my @labels = grep { $_->target_type eq 'label' } @{$c->stash->{data}->{rels}};
        $c->model('Area')->load(map { $_->target } @labels);
        $c->model('Area')->load_codes(map { $_->target->area } @labels);
        $c->model('LabelType')->load(map { $_->target } @labels);

        my @releases = grep { $_->target_type eq 'release' } @{$c->stash->{data}->{rels}};
        for (@releases)
        {
            $_->target->release_group (
                $c->model('ReleaseGroup')->get_by_id($_->target->release_group_id));
        }
        $c->model('ReleaseStatus')->load(map { $_->target } @releases);
        $c->model('ReleaseGroupType')->load(map { $_->target->release_group } @releases);
        $c->model('Script')->load(map { $_->target } @releases);
        $c->model('Language')->load(map { $_->target } @releases);
    }

    $c->model('Area')->load($label);
    $c->model('Area')->load_codes($label->area);
    $c->model('LabelType')->load($label);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label', $label, $c->stash->{inc}, $c->stash->{data}));
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
