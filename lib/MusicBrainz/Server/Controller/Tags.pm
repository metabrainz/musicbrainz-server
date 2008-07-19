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

    $c->stash->{template} = 'tag/display.tt';
}

=head2 all

Show all the tags in the database in a tag cloud

=cut

sub all : Local
{
    my ($self, $c) = @_;

    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});
    my $tags = $t->GetTagHash(200);

    $c->stash->{cloud} = $t->GenerateTagCloud($tags, 'all', 12, 30);
    
    $c->stash->{template} = 'tag/all.tt';
}

1;
