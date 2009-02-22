package MusicBrainz::Server::Controller::AddRelease;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Wizard;
use MusicBrainz::Server::Wizards::AddRelease;
use MusicBrainz::Server::Wizards::AddRelease::ReleaseEvent;
use MusicBrainz::Server::Wizards::AddRelease::Track;

=head2 wizard

Start the wizard

=cut

sub wizard : Chained('/artist/artist') PathPart('add_release') CaptureArgs(0)
{
    my ($self, $c) = @_;
    $c->forward('/user/login');

    $c->stash->{wizard} = MusicBrainz::Server::Wizard->new(
        store => $self->_data($c),
        steps => [
            'track_count',
            'release_data',
            'check_duplicates' => { skip => sub { shift->has_checked_duplicates } },
            'confirm_artists'  => { skip => sub { !shift->has_unconfirmed_artists } },
            'confirm_labels'   => { skip => sub { !shift->has_unconfirmed_labels } },
            'confirm',
        ]
    );
}

=head2 track_count

First step in the add release wizard, requesting a track count from the user.

Navigating to this URL will cause the current wizard state to be reset (upon
sucessful submission).

=cut

sub track_count : Chained('wizard') PathPart
                  Form('AddRelease::TrackCount')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(0);

    return unless $self->submit_and_validate($c);

    my $artist = $c->stash->{artist};
    my $data   = $self->_data($c);

    $data->artist($artist);
    $data->clear_tracks;
    for (1 .. $self->form->value('track_count'))
    {
        $data->add_track(
            MusicBrainz::Server::Wizards::AddRelease::Track->new(
                artist    => $artist->name,
                artist_id => $artist->id,
                sequence  => $_,
            )
        );
    }

    $data->clear_release_events;
    $data->add_release_event(MusicBrainz::Server::Wizards::AddRelease::ReleaseEvent->new);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub release_data : Chained('wizard') PathPart
                   Form('AddRelease::Tracks')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(1);

    my $data = $self->_data($c);
    $data->fill_in_form($self->form);

    return unless $self->submit_and_validate($c);

    my $form = $self->form;

    if ($form->value('more_events'))
    {
        $data->add_release_event(MusicBrainz::Server::Wizards::AddRelease::ReleaseEvent->new);
        $form->add_events(1);
        $self->_data($c, $data);

        $form->field('more_events')->value(undef);
        $c->detach;
    }

    $data->update($self->form);
    $self->_data($c, $data);

    $self->_progress($c);
}

sub check_duplicates : Chained('wizard') PathPart
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

sub confirm_artists : Chained('wizard') PathPart
                      Form('Artist::Create')
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
        return unless $self->form->validate($c->req->params);
        $artist = $self->form->create;
    }

    $confirming->artist($artist->name);
    $confirming->artist_id($artist->id);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub confirm_labels : Chained('wizard') PathPart
                      Form('Label::Create')
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
        return unless $self->form->validate($c->req->params);
        $label = $self->form->create;
    }

    $confirming->label($label->name);
    $confirming->label_id($label->id);

    $self->_data($c, $data);
    $self->_progress($c);
}

sub confirm : Chained('wizard') PathPart Form('Confirm')
{
    my ($self, $c) = @_;

    my $data = $self->_data($c);

    $c->stash->{release} = $data->to_release;
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

    return unless $self->submit_and_validate($c);

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

    delete $c->session->{wizard};

    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_RELEASE } @mods;
    $c->response->redirect($c->uri_for('/release', $add_mods[0]->row_id));
}

=head2 _progress

Change the current step in the wizard, and issue a browser redirect. This will cause
the wizard page to be updated, but will not cause a POST to "fallthrough" to subsequent pages
(which would be the case with forwarding or detaching in Catalyst).

=cut

sub _progress
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $wizard = $c->stash->{wizard};

    my $next_step = $wizard->progress;

    $c->response->redirect(
        $c->uri_for('/artist', $artist->mbid, 'add_release', $next_step->name));
    $c->detach;
}

=head2 _data

Get or set a reference to the current wizard

=cut

sub _data
{
    my $self = shift;
    my $c    = shift;

    my $artist  = $c->stash->{artist};
    my $data;

    if (@_)
    {
        $data = shift;
        $data->artist->dbh(undef);
        $c->session->{add_release}->{$artist->id} = $data->pack;
    }
    else
    {
        my $from_session = $c->session->{add_release}->{$artist->id};
        $data = defined $from_session
            ? MusicBrainz::Server::Wizards::AddRelease->unpack($from_session)
            : MusicBrainz::Server::Wizards::AddRelease->new(
                artist => $c->stash->{artist},
            );
    }

    return $data;
}

1;
