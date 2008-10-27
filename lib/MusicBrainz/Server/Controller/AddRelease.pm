package MusicBrainz::Server::Controller::AddRelease;

use strict;
use warnings;

use base qw(Catalyst::Controller);

use MusicBrainz::Server::Release;

=head2 _current_step

Change the current step of the wizard, but do not cause the wizard to be refreshed

=cut

sub _current_step
{
    my ($self, $c, $new_step) = @_;

    if (defined $new_step) { $c->session->{wizard_step} = $new_step; }
    return $c->session->{wizard_step};
}

=head2 _change_step

Change the current step in the wizard, and issue a browser redirect. This will cause
the wizard page to be updated, but will not cause a POST to "fallthrough" to subsequent pages
(which would be the case with forwarding or detaching in Catalyst).

=cut

sub _change_step
{
    my ($self, $c, $new_step) = @_;

    $self->_current_step($c, $new_step);
    $c->response->redirect($c->req->uri);
}

=head2 _wizard_data

Get a reference to the current data entered into the wizard.

=cut

sub _wizard_data
{
    my ($self, $c) = @_;
    if (!defined $c->session->{wizard}) { $c->session->{wizard} = {}; }

    return $c->session->{wizard};
}

=head2 add_release

Allow users to add a new release to this artist.

This is a multipage wizard which consists of specifying the track count,
then the track information. Following screens allow the user to confirm
the artists/labels (or create them), and then finally enter an edit note.

=cut

sub add_release : Chained('/artist/artist')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward($self->_current_step($c) || 'add_release_track_count');
}

=head2 add_release_track_count

First step in the add release wizard, requesting a track count from the user

=cut

sub add_release_track_count : Private
{
    my ($self, $c) = @_;

    my $form = $c->form(undef, 'AddRelease::TrackCount');
    $c->stash->{template} = 'add_release/track_count.tt';

    return unless $c->form_posted &&
                  $form->validate($c->req->params);

    $self->_wizard_data($c)->{track_count} = $form->value('track_count');

    $self->_change_step($c, 'add_release_information');
}

=head2 add_release_information

This step requests information about the release

=cut

sub add_release_information : Private
{
    my ($self, $c) = @_;

    my $form = $c->form($c->stash->{artist}, 'AddRelease::Tracks');
    my $w = $self->_wizard_data($c);

    if (!$c->form_posted)
    {
        # Try and pre fill with information in the session
        $form->field('artist')->value($w->{artist}->{name});
    }

    my $track_count = $w->{track_count};
    $c->stash->{track_count} = $track_count;

    $form->add_tracks($track_count);

    $c->stash->{template} = 'add_release/tracks.tt';

    if (!$c->form_posted)
    {
        return unless $form->validate($w->{release_info});
    }
    else
    {
        return unless $form->validate($c->req->params);
        $w->{release_info} = $c->req->params;
    }

    for my $i (1 .. $track_count)
    {
        my $key        = "artist_$i";
        my $input_name = $w->{release_info}->{$key};

        if ($input_name ne $w->{confirmed_artists}->{$key}->{name})
        {
            $w->{unconfirmed_artists} ||= {};
            $w->{unconfirmed_artists}->{$key} = $input_name;
        }
    }

    if (scalar keys %{ $w->{unconfirmed_artists} })
    {
        $self->_change_step($c, 'add_release_confirm_artists');
    }
    else
    {
        $form->context($c);
        $form->insert($w->{confirmed_artists});
    }
}

sub add_release_confirm_artists : Private
{
    my ($self, $c) = @_;

    my $w           = $self->_wizard_data($c);
    my $unconfirmed = $w->{unconfirmed_artists};

    if (scalar keys %$unconfirmed == 0)
    {
        $self->_change_step($c, 'add_release_information');
    }

    # Choose who to confirm
    my $key = (keys %$unconfirmed)[0];

    my $id      = $c->req->query_params->{id};
    my $for_key = $c->req->query_params->{for};

    if (defined $id && $for_key eq $key)
    {
        my $artist = $c->model('Artist')->load($id);

        delete $unconfirmed->{$key};

        $w->{confirmed_artists}->{$key}->{name} = $artist->name;
        $w->{confirmed_artists}->{$key}->{id  } = $id;

        $w->{release_info}->{$key} = $artist->name;

        $self->_change_step($c, 'add_release_confirm_artists');
    }

    $c->forward('/search/filter_artist');

    $c->stash->{confirming} = $w->{release_info}->{$key};
    $c->stash->{key       } = $key;

    $c->stash->{template  } = 'add_release/confirm_artist.tt';
}

=head2 restart

Restart the add_release wizard

=cut

sub restart : Chained('/artist/artist') PathPart('add_release/restart')
{
    my ($self, $c) = @_;

    delete $c->session->{wizard};
    delete $c->session->{wizard_step};

    $c->forward('add_release');
}

1;
