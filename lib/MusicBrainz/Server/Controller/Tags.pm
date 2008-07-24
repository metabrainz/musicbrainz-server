package MusicBrainz::Server::Controller::Tags;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(LoadEntity);
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

    unless($tag)
    {
        $c->detach('all');
    }
    
    $type ||= 'all';
    ($type eq 'all' || $type eq 'artist' || $type eq 'label'
        || $type eq 'track' || $type eq 'release')
        or die "$type is not a valid type of entity";

    my @display_types = $type ne 'all' ? ($type)
                                       : ('artist', 'label', 'release', 'track');
    
    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});

    my $limit = ($type eq 'all') ? 10 : 100;
    my $offset = 0;

    for my $tag_type (@display_types)
    {
        my %group = (
            type => $tag_type,
            entities => [],
        );

        my ($entities, $numitems) = $t->GetEntitiesForTag($tag_type, $tag, $limit, $offset);
        for my $entity (@$entities)
        {
            push @{ $group{entities} }, {
                name      => $entity->{name},
                mbid      => $entity->{gid},
                link_type => $tag_type,
                amount    => $entity->{count},
            };
        }

        $group{more} = $numitems > $limit;

        push @{ $c->stash->{tag_groups} }, \%group;
    }

    $c->stash->{tag} = $tag;

    # Function to generate URL for "who tagged this"
    $c->stash->{who_url} = sub {
        my ($entity, $tag) = @_;

        my $action = $self->action_for('who')
            or die "No action?";

        return $c->uri_for($action,
            [ $entity->{link_type}, $entity->{mbid} ], $tag);
    };

    $c->stash->{template} = 'tag/display.tt';
}

=head2 entity

Used for tag information applied to a specific MusicBrainz entity.

=cut

sub entity : PathPart('tags') Chained CaptureArgs(2)
{
    my ($self, $c, $type, $mbid) = @_;

    my $entity = LoadEntity($type, $mbid, $c);

    $c->stash->{entity}  = $entity->ExportStash;
    $c->stash->{_entity} = $entity;
}

=head2 who

Show a list of which moderators applied a certain tag to a certain entity.

=cut

sub who : Chained('entity') Args(1)
{
    my ($self, $c, $tag) = @_;
    
    my $entity = $c->stash->{_entity};
    my $entity_type = $c->stash->{entity}->{link_type};

    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});
    my $tags = $t->GetEditorsForEntityAndTag($entity_type, $entity->GetId, $tag);

    use Data::Dumper;
    die Dumper $tags;
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

    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});
    my $tags = $t->GetTagHash(200);

    $c->stash->{tagcloud} = PrepareForTagCloud($tags);
    
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
