package MusicBrainz::Server::Form::Relate::Url;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

use MusicBrainz;
use MusicBrainz::Server::LinkType;

sub profile
{
    return {
        required => {
            url  => '+MusicBrainz::Server::Form::Field::URL',
            type => 'Select',
        },
        optional => {
            description => 'TextArea',
            edit_note   => 'TextArea',
        }
    }
}

sub validate_type
{
    my ($self) = @_;

    return $self->field('type')->add_error('You must select a relationship type for this URL')
        unless $self->value('type') != '||';

    my $val = $self->value('type');

    my ($id, $attributes, $desc) = split /\|/, $val;
    return;

    return $self->field('type')->add_error('Please select a subtype of the currently selected ' .
                                           'relationship type. The selected relationship type ' .
                                           'is only used for grouping sub-types.')
        unless ($desc && $id);
}

sub options_type
{
    my $self = shift;

    my $entity = $self->item;
    my $type   = $entity->entity_type;
    $type =~ s/release/album/; # TODO terminology hack...

    my $mb = new MusicBrainz;
    $mb->Login;

    my $lt = new MusicBrainz::Server::LinkType($mb->{DBH}, [ $type, 'url' ]);
    my $root = $lt->Root;

    my @options;

    push @options, ('||', "[Please select a relationship type]");

    my @q = map { [$_,0] } $root;
    while (my $l = shift @q)
    {
        unshift @q, map { [$_,$l->[1]+1] } $l->[0]->Children;
        next if ($l->[0]->name eq "ROOT");
        next if ($l->[0]->id == 32); # Add CC license -- don't show here, let people go to addcc

        my $text = $l->[0]->GetLinkPhrase;
        $text =~ s/\{(\w+:)/{/;

        # add x times indentation like specified in the relationship type hierarchy
        $text = ("&nbsp;&nbsp;" x $l->[1]) . $text;

        my $value = $l->[0]->id . "|" . $l->[0]->attributes;

        push @options, ($value, $text);
    }

    return \@options;
}

sub mod_type { ModDefs::MOD_ADD_LINK }

sub build_options
{
    my ($self) = @_;

    my $source = $self->item;

    my $type = $source->entity_type;
    $type =~ s/release/album/; # TODO terminology hack...

    my $lt = new MusicBrainz::Server::LinkType($self->context->mb->{DBH}, [ $type, 'url']);

    my ($linkid, $linkattributes, $linkdesc) = split /\|/, $self->value('type');
    my $link = $lt->newFromId($linkid);

    my @links;
    push @links, {
        type => $type,
        id   => $source->id,
        obj  => $source,
        name => $source->name,
    };
    push @links, {
        type => "url",
        id   => undef,
        obj  => undef,
        name => $self->value('url'),
        url  => $self->value('url'),
        desc => $self->value('description') || '',
    };

    return {
        entities => \@links,
        linktype => $link,
        url      => $self->value('url'),
    };
}

1;
