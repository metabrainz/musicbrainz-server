package MusicBrainz::Server::Controller::Label;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(EntityUrl);

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

sub perma : Chained('label') { }

=head2 aliases

Display all aliases for a label

=cut

sub aliases : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($label);
}

=head2 tags

Display a tag-cloud of tags for a label

=cut

sub tags : Chained('label')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{label};

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($label);
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
}

=head2 show

Show this label to a user, including a summary of ARs, and the releases
that have been released through this label

=cut

sub show : PathPart('') Chained('label')
{
    my ($self, $c) = @_;

    my $label    = $c->stash->{label};
    my $releases = $c->model('Release')->load_for_label($label);

    $c->stash->{releases}  = $releases;
    $c->stash->{relations} = $c->model('Relation')->load_relations($label);
}

=head2 details

Display detailed information about a given label

=cut

sub details : Chained('label') { }

=head2 WRITE METHODS

=cut

sub merge : Chained('label')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $c->form(undef, 'Search::Query');

    return unless $c->form_posted && $form->validate($c->req->params);
    
    my $label = $c->stash->{label};

    my $labels = $c->model('Label')->direct_search($form->value('query'));
    $c->stash->{labels} = $labels;
}

sub merge_into : Chained('label') PathPart('into') Args(1)
{
    my ($self, $c, $new_mbid) = @_;

    $c->forward('/user/login');

    my $label     = $c->stash->{label};
    my $new_label = $c->model('Label')->load($new_mbid);
    $c->stash->{new_label} = $new_label;

    my $form = $c->form($label, 'Label::Merge');
    $form->context($c);

    $c->stash->{template} = 'label/merge.tt';

    return unless $c->form_posted && $form->validate($c->req->params);

    my @mods = $form->perform_merge($new_label);

    $c->flash->{ok} = "Thanks, your label edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($new_label, 'show'));
}

1;
