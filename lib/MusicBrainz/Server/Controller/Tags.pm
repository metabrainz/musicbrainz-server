package MusicBrainz::Server::Controller::Tags;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(LoadEntity);
use MusicBrainz::Server::Adapter::Tag qw(PrepareForTagCloud);
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

sub entity : PathPart('tags') Chained CaptureArgs(2)
{
    my ($self, $c, $type, $mbid) = @_;

    my $entity = LoadEntity($type, $mbid);

    $c->stash->{entity}  = $entity->ExportStash;
    $c->stash->{_entity} = $entity;
}

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

1;
