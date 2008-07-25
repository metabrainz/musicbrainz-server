package MusicBrainz::Server::Controller::Label;

use strict;
use warnings;

use base 'Catalyst::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Label

=head1 DESCRIPTION

Handles user interaction with label entities

=head1 METHODS

=head2 label

Chained action to load the label into the stash.

=cut

sub label : Chained CaptureArgs(1)
{
    my ($self, $c, $mbid) = @_;

    $c->stash->{label} = $c->model('Label')->load($mbid);
}

=head2 perma

Display details about a permanant link to this label.

=cut

sub perma : Chained('label')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'label/perma.tt';
}

=head2 aliases

Display all aliases for a label

=cut

sub aliases : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($label);
    $c->stash->{template} = 'label/aliases.tt';
}

=head2 tags

Display a tag-cloud of tags for a label

=cut

sub tags : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($label);
    $c->stash->{template} = 'label/tags.tt';
}

=head2 google

Redirect to Google and search for this label (using MusicBrainz colours).

=cut

sub google : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    $c->response->redirect(Google($label->name));
}

=head2 relations

Show all relations to this label

=cut

sub relations : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{_label};
  
    $c->stash->{relations} = load_relations($label);

    $c->stash->{template}  = 'label/relations.tt';
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : PathPart('') Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    my $releases = $c->model('Release')->load_for_label($label);
    $c->stash->{releases}  = $releases;

    $c->stash->{relations} = $c->model('Relation')->load_relations($label);

    $c->stash->{template} = 'label/show.tt';
}

=head2 details

Display detailed information about a given label

=cut

sub details : Chained('label')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'label/details.tt';
}

1;
