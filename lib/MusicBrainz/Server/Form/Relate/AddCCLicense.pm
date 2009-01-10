package MusicBrainz::Server::Form::Relate::AddCCLicense;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz;
use MusicBrainz::Server::LinkAttr;
use MusicBrainz::Server::LinkType;

sub profile
{
    shift->with_mod_fields({
        required => {
            license => 'Select',
            url     => '+MusicBrainz::Server::Form::Field::URL',
        },
    });
}

sub options_license
{
    my ($self) = @_;

    my $mb = new MusicBrainz;
    $mb->Login;

    # Load the top level link attributes
    my $attrType = MusicBrainz::Server::LinkAttr->new($mb->{dbh});
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

sub mod_type { ModDefs::MOD_ADD_LINK }

sub build_options
{
    my $self = shift;

    my $entity = $self->item;

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

    my $link = MusicBrainz::Server::LinkType->new($self->context->mb->{dbh}, \@types);

    my $linktype = $link->newFromId($linktypeid);

    my ($license) = split /\|/, $self->value('license');

    return {
        entities   => \@links,
        linktype   => $linktype,
        url        => $self->value('url'),
        attributes => [ {
            name  => 'license',
            value => $license,
        } ]
    };
}

1;
