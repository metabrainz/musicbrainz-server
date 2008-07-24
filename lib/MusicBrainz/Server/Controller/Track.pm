package MusicBrainz::Server::Controller::Track;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(LoadEntity);
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

    my $entity = MusicBrainz::Server::Track->new($c->mb->{DBH});
    LoadEntity($entity, $mbid);

    $c->stash->{_track} = $entity;
    $c->stash->{track}  = $entity->ExportStash;
}

=head2 relations

Shows all relations to a given track

=cut

sub relations : Chained('track')
{
    my ($self, $c, $mbid) = @_;

    my $track = $c->stash->{_track};
    $c->stash->{relations} = LoadRelations($track, 'track');;

    $c->stash->{template} = 'track/relations.tt';
}

=head2 show

Show details of a track

=cut

sub show : Chained('track') PathPart('')
{
    my ($self, $c) = @_;

    $c->detach('relations');
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
