package MusicBrainz::Server::Form::Relate::AddCCLicense;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz;
use MusicBrainz::Server::LinkAttr;
use MusicBrainz::Server::LinkType;

sub profile
{
    return {
        required => {
            license => 'Select',
            url     => '+MusicBrainz::Server::Form::Field::URL',
        },
        optional => {
            edit_note => 'TextArea',
        }
    };
}

sub options_license
{
    my ($self) = @_;

    my $mb = new MusicBrainz;
    $mb->Login;

    # Load the top level link attributes
    my $attrType = MusicBrainz::Server::LinkAttr->new($mb->{DBH});
    my $root = $attrType->Root;
    my @children = $root->Children;
    my @cclics;

    foreach my $node (@children)
    {
        if ($node->name =~ /license/)
        {
            my @lics = $node->Children;
            foreach my $child (@lics)
            {
                if ($child->name =~ /Creative Commons/)
                {
                    @cclics = $child->Children;
                    last;
                }
            }
            last;
        }
    }

    return map { $_->id . "|" => $_->name } @cclics;
}

sub add_relationship
{
    my $self = shift;

    my $entity = $self->item;
    my $user   = $self->context->user;

    my $linktypeid = $entity->entity_type eq 'release' ? 32
                   : $entity->entity_type eq 'track'   ? 21
                   :                                     0;

    my $type = $entity->entity_type;
    $type =~ s/release/album/;

    my @links;
    push @links, {
        type => $type,
        id   => $entity->id,
        obj  => $entity,
        name => $entity->name,
    };
    push @links, {
        type => 'url',
        id   => undef,
        obj  => undef,
        name => $self->value('url'),
        url  => $self->value('url'),
        desc => "",
    };

    my @types = ($type, 'url');

    my $link = MusicBrainz::Server::LinkType->new($self->context->mb->{DBH}, \@types);

    my $linktype = $link->newFromId($linktypeid);

    my ($license) = split /\|/, $self->value('license');

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_ADD_LINK,

        entities   => \@links,
        linktype   => $linktype,
        url        => $self->value('url'),
        attributes => [ {
            name  => 'license',
            value => $license,
        } ]
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;
    };

    return \@mods;
}

1;
