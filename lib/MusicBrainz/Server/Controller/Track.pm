package MusicBrainz::Server::Controller::Track;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(Google);
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Track

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Track> entities.

=head1 METHODS

=head2 track

Chained action to load a track

=cut

sub track : Chained CaptureArgs(1)
{ 
    my ($self, $c, $mbid) = @_;

    my $track = $c->model('Track')->load($mbid);

    $c->stash->{track}  = $track;
    $c->stash->{artist} = $c->model('Artist')->load($track->artist_id);
}

=head2 relations

Shows all relations to a given track

=cut

sub relations : Chained('track')
{
    my ($self, $c, $mbid) = @_;
    my $track = $c->stash->{track};

    $c->stash->{relations} = $c->model('Relation')->load_relations($track);
    $c->stash->{template}  = 'track/relations.tt';
}

=head2 details

Show details of a track

=cut

sub details : Chained('track')
{
    my ($self, $c) = @_;
    my $track = $c->stash->{track};

    $c->stash->{relations} = $c->model('Relation')->load_relations($track);
    $c->stash->{tags}      = $c->model('Tag')->top_tags($track);
    $c->stash->{release}   = $c->model('Release')->load($track->release_id);

    $c->stash->{template} = 'track/info.tt';
}

sub show : Chained('track') PathPart('')
{
    my ($self, $c) = @_;
    $c->detach('details');
}

sub tags : Chained('track')
{
    my ($self, $c, $mbid) = @_;
    my $track = $c->stash->{track};

    $c->stash->{tags}     = $c->model('Tag')->generate_tag_cloud($track);
    $c->stash->{template} = 'track/tags.tt';
}

sub google : Chained('track')
{
    my ($self, $c) = @_;
    my $track = $c->stash->{track};

    $c->response->redirect(Google($track->name));
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
