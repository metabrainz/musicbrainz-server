package MusicBrainz::Server::Form::Relate::Url;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz;
use MusicBrainz::Server::LinkType;

sub name { 'add-url-relationship' }

sub profile
{
    shift->with_mod_fields({
        required => {
            url  => '+MusicBrainz::Server::Form::Field::URL',
            type => 'Select',
        },
        optional => {
            description => 'TextArea',
        }
    });
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

    return unless $self->item;

    my $entity = $self->item;
    my $type   = $entity->entity_type;
    $type =~ s/release/album/; # TODO terminology hack...

    my $mb = new MusicBrainz;
    $mb->Login;

    my $lt = new MusicBrainz::Server::LinkType($mb->dbh, [ $type, 'url' ]);
    my $root = $lt->root;

    my @options = ('||', "[ Please select a relationship type ]");

    # @nodes is a list of [ node, hierarchy level ]
    my @nodes = ( [ $root, 0] );
    while (my $n = shift @nodes)
    {
        my $node = $n->[0];
        unshift @nodes, map { [ $_, $n->[1] + 1 ] } $node->children;
        next if ($node->name eq "ROOT");
        next if ($node->id == 32); # Add CC license -- don't show here, let people go to addcc

        my $text = $node->link_phrase;
        $text =~ s/\{(\w+:)/{/;

        # add x times indentation like specified in the relationship type hierarchy
        $text = ("&nbsp;&nbsp;" x $n->[1]) . $text;

        my $value = $node->id . "|" . ($node->attributes || '');

        push @options, ($value, $text);
    }

    return \@options;
}

sub create_relationship
{
    my $self = shift;

    $self->context->model('Relation')->relate_to_url(
        $self->item,
        $self->value('url'),
        $self->value('type'),
        $self->value('description'),
        $self->value('edit_note')
    );
}

1;
