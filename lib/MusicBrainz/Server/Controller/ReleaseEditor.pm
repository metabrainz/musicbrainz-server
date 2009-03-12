package MusicBrainz::Server::Controller::ReleaseEditor;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Wizard;
use MusicBrainz::Server::Wizards::ReleaseEditor;
use MusicBrainz::Server::Wizards::ReleaseEditor::ReleaseEvent;
use MusicBrainz::Server::Wizards::ReleaseEditor::Track;

__PACKAGE__->config->{namespace} = 'release_editor';

=head2 wizard

Start the wizard

=cut

sub wizard : Chained('/') PathPart('release_editor') CaptureArgs(1)
{
    my ($self, $c, $wizard_index) = @_;
    $c->forward('/user/login');
    $c->stash->{wizard_index} = $wizard_index;

    if ($c->req->params->{cancel})
    {
        $self->_delete_wizard($c);
        $c->response->redirect($c->entity_url($c->stash->{artist}, 'show'));
        $c->detach;
    }

    $c->stash->{wizard} = MusicBrainz::Server::Wizard->new(
        store => $self->_data($c),
        steps => [
            'track_count'      => { name => 'Track Count' },
            'release_data'     => { name => 'Release Data' },
            'check_duplicates' => { name => 'Check Duplicate Releases', skip => sub { shift->has_checked_duplicates } },
            'confirm_artists'  => { name => 'Confirm Track Artists', skip => sub { !shift->has_unconfirmed_artists } },
            'confirm_labels'   => { name => 'Confirm Release Event Labels', skip => sub { !shift->has_unconfirmed_labels } },
            'confirm'          => { name => 'Confirm/Preview' },
        ]
    );

    $c->stash->{artist} = $self->_data($c)->artist;
    $c->stash->{artist}->dbh($c->mb->dbh);
}

=head2 track_count

First step in the add release wizard, requesting a track count from the user.

Navigating to this URL will cause the current wizard state to be reset (upon
sucessful submission).

=cut

sub track_count : Chained('wizard') Form('AddRelease::TrackCount')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(0);

    return unless $self->submit_and_validate($c);

    my $artist = $c->stash->{artist};
    my $data   = $self->_data($c);

    $data->clear_tracks;
    for (1 .. $self->form->value('track_count'))
    {
        $data->add_track(
            MusicBrainz::Server::Wizards::ReleaseEditor::Track->new(
                artist    => $artist->name,
                artist_id => $artist->id,
                sequence  => $_,
            )
        );
    }

    $data->clear_release_events;
    $data->add_release_event(MusicBrainz::Server::Wizards::ReleaseEditor::ReleaseEvent->new);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub release_data : Chained('wizard') Form('AddRelease::Tracks')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(1);

    my $data = $self->_data($c);
    $data->fill_in_form($self->form);

    return unless $self->submit_and_validate($c);

    my $form = $self->form;

    if ($form->value('more_events'))
    {
        $data->add_release_event(MusicBrainz::Server::Wizards::ReleaseEditor::ReleaseEvent->new);
        $form->add_events(1);
        $self->_data($c, $data);

        $form->field('more_events')->value(undef);
        $c->detach;
    }

    $data->update($self->form);
    $self->_data($c, $data);

    $self->_progress($c);
}

sub check_duplicates : Chained('wizard')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(2);

    my $artist = $c->stash->{artist};
    my $data   = $self->_data($c);

    unless ($c->form_posted)
    {
        my $similar = $c->model('Release')->find_similar_releases($artist, $data->name, $data->track_count);
        if (scalar @$similar)
        {
            $c->stash->{similar} = [
                map {
                    $_->LoadFromId;
                    {
                        release => $_,
                        tracks  => $c->model('Track')->load_from_release($_),
                        events  => $c->model('Release')->load_events($_),
                    };
                } @$similar
            ];

            $c->detach;
        }
    }

    $data->has_checked_duplicates(1);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub confirm_artists : Chained('wizard') Form('Artist::Create')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(3);

    my $artist = $c->stash->{artist};
    my $data   = $self->_data($c);

    my $to_confirm = $data->unconfirmed_artists;

    $self->_progress($c)
        if scalar @$to_confirm == 0;

    my $confirming = $to_confirm->[0];
    $c->stash->{confirming} = $confirming->to_track->artist;

    $c->forward('/search/filter_artist');

    $c->stash->{create_artist} = $self->form;

    return unless $c->form_posted;

    $artist = $c->stash->{search_result};
    if (!defined $artist)
    {
        return unless $c->req->params->{do_add_artist} &&
            $self->form->validate($c->req->params);
        $artist = $self->form->create;
    }

    $confirming->artist($artist->name);
    $confirming->artist_id($artist->id);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub confirm_labels : Chained('wizard') Form('Label::Create')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(4);

    my $data       = $self->_data($c);
    my $to_confirm = $data->unconfirmed_labels;

    $self->_progress($c)
        if scalar @$to_confirm == 0;

    my $confirming = $to_confirm->[0];
    $c->stash->{confirming} = $confirming->to_event->label;

    $c->forward('/search/filter_label');

    $c->stash->{create_label} = $self->form;

    return unless $c->form_posted;

    my $label = $c->stash->{search_result};

    if (!defined $label)
    {
        return unless exists $c->req->params->{do_add_label} &&
            $self->form->validate($c->req->params);
        $label = $self->form->create;
    }

    $confirming->label($label->name);
    $confirming->label_id($label->id);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub confirm : Chained('wizard') Form('Confirm')
{
    my ($self, $c) = @_;

    my $data = $self->_data($c);

    $c->stash->{release} = $data->to_release;
    $c->stash->{release}->dbh($c->mb->dbh);

    $c->stash->{tracks}  = [ map { $_->to_track } @{ $data->accepted_tracks } ];
    $c->stash->{release_events}  = [ map { $_->to_event } @{ $data->accepted_release_events } ];

    # Load countries for release events
    my $country_obj = MusicBrainz::Server::Country->new($c->mb->dbh);
    my %county_names;

    for my $event (@{ $c->stash->{release_events }})
    {
        my $cid = $event->country;
        $event->country(
            $county_names{$cid} ||= do {
                my $country = $country_obj->newFromId($cid);
                $country ? $country->name : "?";
            }
        );
    }

    $self->form->field('edit_note')->value($data->edit_note);

    return unless $self->submit_and_validate($c);

    if ($c->req->params->{keep_editing})
    {
        $data->edit_note($self->form->value('edit_note'));
        $self->_data($c, $data);

        $self->_redirect_to_step($c, 'release_data');
    }

    my %opts = (
        AlbumName => $data->name,
        artist    => $data->artist->id,
        type      => ModDefs::MOD_ADD_RELEASE,
        HasMultipleTrackArtists => 1,
    );

    for my $track (@{ $data->accepted_tracks })
    {
        my $i = $track->sequence;
        $opts{"Track$i"}    = $track->name;
        $opts{"ArtistID$i"} = $track->artist_id;
        $opts{"TrackDur$i"} = $track->duration;
    }

    my $i = 1;
    for my $event (@{ $data->accepted_release_events })
    {
        $event = $event->to_event;
        $opts{"Release$i"} = sprintf("%s,%s-%s-%s,%s,%s,%s,%s",
            $event->country,
            $event->year  || '',
            $event->month || '',
            $event->day   || '',
            $event->label->id,
            $event->cat_no,
            $event->barcode,
            $event->format,
        );
        $i++;
    }

    my @mods = $c->model('Moderation')->insert(
        $self->form->value('edit_note'),
        %opts
    );

    $self->_delete_wizard($c);

    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_RELEASE } @mods;
    $c->response->redirect($c->uri_for('/release', $add_mods[0]->row_id));
}

=head2 add_release

Private method that other controllers can forward to, in order to
begin adding a new release to an artist.

Requries $c->stash->{artist} to be set to a MusicBrainz::Server::Artist
instance.

=cut

sub add_release : Private
{
    my ($self, $c) = @_;

    $c->stash->{wizard_index} = time;

    my $data = $self->_data($c);
    $data->artist($c->stash->{artist});
    $self->_data($c, $data);

    $self->_redirect_to_step($c, 'track_count');
}

=head2 _delete_wizard

Clear the current wizard from the session

=cut

sub _delete_wizard : Private
{
    my ($self, $c) = @_;

    my $index = $c->stash->{wizard_index};
    delete $c->session->{"release_editor_$index"};
}

=head2 _progress

Change the current step in the wizard, and issue a browser redirect. This will cause
the wizard page to be updated, but will not cause a POST to "fallthrough" to subsequent pages
(which would be the case with forwarding or detaching in Catalyst).

=cut

sub _progress
{
    my ($self, $c) = @_;

    my $wizard = $c->stash->{wizard};
    my $next_step = $wizard->progress;
    $self->_redirect_to_step($c, $next_step->action_name);
}

=head2 _redirect_to_step $c, $step

Redirect to a specific step

=cut

sub _redirect_to_step
{
    my ($self, $c, $step) = @_;

    $c->response->redirect($c->uri_for('/release_editor', $c->stash->{wizard_index}, $step));
    $c->detach;
}

=head2 _data

Get or set a reference to the current wizard

=cut

sub _data
{
    my $self = shift;
    my $c    = shift;

    my $data;
    my $index  = $c->stash->{wizard_index};

    if (@_)
    {
        $data = shift;
        $data->artist->dbh(undef);
        $c->session->{"release_editor_$index"} = $data->pack;
    }
    else
    {
        my $from_session = $c->session->{"release_editor_$index"};
        $data = defined $from_session
            ? MusicBrainz::Server::Wizards::ReleaseEditor->unpack($from_session)
            : MusicBrainz::Server::Wizards::ReleaseEditor->new(
                artist => $c->stash->{artist},
            );
    }

    return $data;
}

1;
