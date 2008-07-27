package MusicBrainz::Server::Controller::Tags;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Label;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Tag

=head1 DESCRIPTION

Handles user interaction with folksonomy tags

=head1 METHODS

=head2 display

Display all entities that relate to a given tag.

=cut

sub display : Path
{
    my ($self, $c, $tag, $type) = @_;

    $c->detach('all')
        unless($tag);
    
    $type ||= 'all';
    unless ($type eq 'all'      ||
            $type eq 'artist'   ||
            $type eq 'label'    ||
            $type eq 'track'    ||
            $type eq 'release')
    {
        die "$type is not a valid type of entity";
    }

    my @display_types = $type ne 'all' ? ($type)
                      :                  ('artist', 'label', 'release', 'track');
    
    my $limit = ($type eq 'all') ? 10 : 100;
    my $offset = 0;

    $c->stash->{tag_types} = [];
    for my $tag_type (@display_types)
    {
        push @{ $c->stash->{tag_types} }, {
            type     => $tag_type,
            entities => $c->model('Tag')->tagged_entities($tag, $tag_type, $limit, $offset),
        }
    }

    $c->stash->{tag} = $tag;

    $c->stash->{template} = 'tag/display.tt';
}

=head2 entity

Used for tag information applied to a specific MusicBrainz entity.

=cut

sub entity : PathPart('tags') Chained CaptureArgs(2)
{
    my ($self, $c, $type, $mbid) = @_;
    $c->stash->{entity}  = $c->model(ucfirst $type)->load($mbid);
}

=head2 new

Used to add a new tag to an entity

=cut

sub new : Chained('entity') PathPart
{
}

=head2 all

Show all the tags in the database in a tag cloud

=cut

sub all : Local
{
    my ($self, $c) = @_;

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud();
    
    $c->stash->{template} = 'tag/all.tt';
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
