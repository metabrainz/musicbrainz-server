package MusicBrainz::Server::Controller::ReleaseEditor;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Form::ReleaseEditor::Tracks;
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

    unless (exists $c->session->{"release_editor_$wizard_index"})
    {
        $c->stash->{message} = "The requested wizard session ($wizard_index) does not exist";
        $c->detach('/error_500');
    }

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
            'confirm_artists'  => { name => 'Confirm Track Artists', skip => sub { !shift->has_unconfirmed_artists } },
            'check_duplicates' => { name => 'Check Duplicate Releases', skip => sub { shift->has_checked_duplicates } },
            'confirm_labels'   => { name => 'Confirm Release Event Labels', skip => sub { !shift->has_unconfirmed_labels } },
            'confirm'          => { name => 'Confirm/Preview' },
        ]
    );

    $c->stash->{artist} = $self->_data($c)->artist_model;
    $c->stash->{artist}->dbh($c->mb->dbh);
}

=head2 track_count

First step in the add release wizard, requesting a track count from the user.

Navigating to this URL will cause the current wizard state to be reset (upon
sucessful submission).

=cut

sub track_count : Chained('wizard') Form('ReleaseEditor::TrackCount')
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

sub release_data : Chained('wizard') Form('ReleaseEditor::Tracks')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(1);

    my $data = $self->_data($c);
    $data->fill_in_form($self->form);

    return unless $self->submit_and_validate($c);

    my $form = $self->form;

    my $form_changed;
    if ($form->value('more_events'))
    {
        $data->add_release_event(MusicBrainz::Server::Wizards::ReleaseEditor::ReleaseEvent->new);
        $form->add_events(1);
        $self->_data($c, $data);

        $form->field('more_events')->value(undef);
        $form_changed = 1;
    }

    if ($form->value('more_tracks'))
    {
        $data->add_track(MusicBrainz::Server::Wizards::ReleaseEditor::Track->new(
            artist    => $data->artist,
            artist_id => $data->artist_id
        ));
        $self->_data($c, $data);

        $form_changed = 1;
    }

    if ($form_changed)
    {
        $form = MusicBrainz::Server::Form::ReleaseEditor::Tracks->new;
        $data->fill_in_form($form);

        $c->stash->{form} = $form;
        $c->detach;
    }

    $data->update($self->form);
    $self->_data($c, $data);

    $self->_progress($c);
}

sub confirm_artists : Chained('wizard') Form('Artist::Create')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(2);

    my $artist = $c->stash->{artist};
    my $data   = $self->_data($c);

    my $to_confirm = $data->unconfirmed_artists;

    $self->_progress($c)
        if scalar @$to_confirm == 0;

    my $confirming = $to_confirm->[0];
    $c->stash->{confirming} = $confirming->artist_model;

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

sub check_duplicates : Chained('wizard')
{
    my ($self, $c) = @_;
    $c->stash->{wizard}->current_step_index(3);

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
    $c->stash->{wizard}->current_step_index(5);

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

    $c->forward($data->is_edit ? '_do_edit' : '_do_add');
    $self->_delete_wizard($c);

    $c->response->redirect($c->uri_for('/release', $c->stash->{release_id}));
}

sub _do_add : Private
{
    my ($self, $c) = @_;
    my $data = $self->_data($c);

    my %opts = (
        AlbumName => $data->name,
        artist    => $data->artist_id,
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

    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_RELEASE } @mods;
    $c->stash->{release_id} = $add_mods[0]->row_id;
}

sub _do_edit : Private
{
    my ($self, $c) = @_;

    my $index = $c->stash->{wizard_index};
    my $release_id = $c->session->{"release_editor_$index"}->{old_release};
    my $release = $c->model('Release')->load($release_id);

    my $data = $self->_data($c);
    my @edits;

    # MOD_MOVE_RELEASE
    if ($data->artist_id ne $release->artist)
    {
        $c->log->info($release->artist);
        my $artist = $c->model('Artist')->load($data->artist_id);
        my $old    = $c->model('Artist')->load($release->artist);
        push @edits, $c->model('Moderation')->insert(undef,
            type           => ModDefs::MOD_MOVE_RELEASE,
            album          => $release,
            oldartist      => $old,
            artistid       => $artist->id,
            artistsortname => $artist->sort_name,
            artistname     => $artist->name,
        );
    }

    # MOD_EDIT_RELEASE_NAME
    if ($data->name ne $release->name)
    {
        push @edits, $c->model('Moderation')->insert(undef,
            type    => ModDefs::MOD_EDIT_RELEASE_NAME,
            album   => $release,
            newname => $data->name
        );
    }

    # MOD_EDIT_RELEASE_ATTRS
    my $new = join ",", ($data->release_type, $data->release_status);
    my $old = join ",", $release->release_type_and_status;
    if ($new ne $old)
    {
        push @edits, $c->model('Moderation')->insert(undef,
            type        => ModDefs::MOD_EDIT_RELEASE_ATTRS,
            albums      => [ $release ],
            attr_type   => $data->release_type,
            attr_status => $data->release_status
        );
    }

    # MOD_EDIT_RELEASE_LANGUAGE
    $new = join ",", ($data->language, $data->script);
    $old = join ",", ($release->language, $release->script);
    if ($new ne $old)
    {
        push @edits, $c->model('Moderation')->insert(undef,
            type        => ModDefs::MOD_EDIT_RELEASE_LANGUAGE,
            albums      => [ $release ],
            language    => $data->language,
            script      => $data->script
        );
    }

    # Release Event edits
    my (@remove_events, @edit_events, @add_events);
    for my $event (@{ $data->release_events })
    {
        my $rev = $event->to_event;
        $rev->release($release->id);
        $rev->dbh($c->mb->dbh);

        if ($event->removed)
        {
            push @remove_events, $rev;
        }
        elsif (!$event->id)
        {
            push @add_events, $rev;
        }
        else
        {
            # Could be an edit
            my $old = $c->model('Release')->load_event($event->id);
            if ($rev->cat_no ne $old->cat_no or
                $rev->format != $old->format or
                $rev->barcode ne $old->barcode or
                $rev->sort_date ne $old->sort_date or
                $rev->label->id != $old->label->id or
                $rev->country != $old->country)
            {
                push @edit_events, {
                    object  => $old,
                    country => $rev->country,
                    year    => $rev->year,
                    month   => $rev->month,
                    day     => $rev->day,
                    catno   => $rev->cat_no,
                    barcode => $rev->barcode,
                    format  => $rev->format,
                    label   => $rev->label,
                };
            }
        }
    }

    # MOD_ADD_RELEASE_EVENTS
    push @edits, $c->model('Moderation')->insert(undef,
        type => ModDefs::MOD_ADD_RELEASE_EVENTS,
        album => $release,
        adds => \@add_events,
    );

    # MOD_REMOVE_RELEASE_EVENTS
    push @edits, $c->model('Moderation')->insert(undef,
        type    => ModDefs::MOD_REMOVE_RELEASE_EVENTS,
        album   => $release,
        removes => \@remove_events
    );

    # MOD_EDIT_RELEASE_EVENTS
    push @edits, $c->model('Moderation')->insert(undef,
        type  => ModDefs::MOD_EDIT_RELEASE_EVENTS,
        album => $release,
        edits => \@edit_events
    );

    # Track level edits
    for my $track (@{ $data->tracks })
    {
        if ($track->has_id)
        {
            my $original = $c->model('Track')->load($track->id);

            # MOD_REMOVE_TRACK
            if ($track->removed)
            {
                push @edits, $c->model('Moderation')->insert(undef,
                    type  => ModDefs::MOD_REMOVE_TRACK,
                    track => $original,
                    album => $release,
                );

                next;
            }

            # MOD_EDIT_TRACK_NAME
            if ($original->name ne $track->name)
            {
                push @edits, $c->model('Moderation')->insert(undef,
                    type   => ModDefs::MOD_EDIT_TRACKNAME,
                    track  => $original,
                    newname => $track->name
                );
            }

            # MOD_EDIT_TRACKTIME
            if ($original->length != $track->duration)
            {
                push @edits, $c->model('Moderation')->insert(undef,
                    type      => ModDefs::MOD_EDIT_TRACKTIME,
                    track     => $original,
                    newlength => $track->duration
                )
            }

            # MOD_EDIT_TRACKNUM
            if ($original->sequence != $track->sequence)
            {
                push @edits, $c->model('Moderation')->insert(undef,
                    type      => ModDefs::MOD_EDIT_TRACKNUM,
                    track     => $original,
                    newseq    => $track->sequence
                )
            }

            # MOD_CHANGE_TRACK_ARTIST
            if ($original->artist->id != $track->artist_id)
            {
                my $old_artist = $c->model('Artist')->load($original->artist->id);
                my $new_artist = $c->model('Artist')->load($track->artist_id);

                push @edits, $c->model('Moderation')->insert(undef,
                    type           => ModDefs::MOD_CHANGE_TRACK_ARTIST,
                    track          => $original,
                    oldartist      => $old_artist,
                    artistid       => $new_artist->id,
                    artistname     => $new_artist->name,
                    artistsortname => $new_artist->sort_name
                );
            }
        }
        else
        {
            # MOD_ADD_TRACK_KV
            push @edits, $c->model('Moderation')->insert(undef,
                type        => ModDefs::MOD_ADD_TRACK_KV,
                album       => $release,
                trackname   => $track->name,
                tracknum    => $track->sequence,
                tracklength => $track->duration,
                artistid    => $track->artist_id,
            );
        }
    }

    # Attach notes to edits
    my $number_edits = scalar @edits;
    for my $i (1 .. $number_edits)
    {
        my $edit = $edits[$i];
        next unless defined $edit;

        if ($number_edits > 1)
        {
            # If we have more than 1 edit, we add notes to clarify they are
            # "related" edits
            my $note_text = sprintf "The %s%s of a set of %d edits",
                                $i,
                                MusicBrainz::Server::Validation::OrdinalNumberSuffix($i),
                                $number_edits;

            $note_text .= sprintf "(beggining with edit #%d)", $edits[0]->id
                if $i == 1;

            $edit->InsertNote(ModDefs::MODBOT_MODERATOR, $note_text, nosend => 1);
        }

        # Copy the users edit note over everything
        $edit->InsertNote($c->user->id, $data->edit_note);
    }

    $c->stash->{release_id} = $release->id;
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
    $data->artist($c->stash->{artist}->name);
    $data->artist_id($c->stash->{artist}->id);
    $self->_data($c, $data);

    $self->_redirect_to_step($c, 'track_count');
}

sub _load_release : Private
{
    my ($self, $c) = @_;

    $c->stash->{wizard_index} = time;
    my $data = $self->_data($c);

    my $artist  = $c->stash->{artist};
    my $release = $c->stash->{release};
    my $events  = $c->stash->{release_events};
    my $tracks  = $c->stash->{tracks};

    $data->artist($artist->name);
    $data->artist_id($artist->id);

    # Release
    $data->name($release->name);
    $data->release_type($release->release_type);
    $data->release_status($release->release_status);
    $data->language($release->language->id) if defined $release->language;
    $data->script($release->script->id) if defined $release->script;
    $data->id($release->id);

    # Tracks
    for my $track (@$tracks)
    {
        $data->add_track(MusicBrainz::Server::Wizards::ReleaseEditor::Track->new(
            artist_id => $track->artist->id,
            artist    => $track->artist->name,
            sequence  => $track->sequence,
            duration  => $track->length,
            name      => $track->name,
            id        => $track->id,
        ));
    }

    # Release Events
    for my $event (@$events)
    {
        my $re = MusicBrainz::Server::Wizards::ReleaseEditor::ReleaseEvent->new(
            barcode  => $event->barcode,
            format   => $event->format,
            catno    => $event->cat_no,
            country  => $event->country,
            date     => $event->sort_date,
            id       => $event->id
        );

        if($event->label->name)
        {
            $re->label($event->label->name);
            $re->label_id($event->label->id);
        }

        $data->add_release_event($re);
    }

    $self->_data($c, $data);
}

=head2 edit_release

Copy a release from the stash into the release editor, allowing the
user to edit details.

=cut

sub edit_release : Private
{
    my ($self, $c) = @_;
    $c->forward('_load_release');

    # Store the old release ID so we can look it up when we confim the edit
    my $index = $c->stash->{wizard_index};
    my $release = $c->stash->{release};
    $c->session->{"release_editor_$index"}->{old_release} = $release->id;

    $self->_redirect_to_step($c, 'release_data');
}

=head2 duplicate_release

Copy a release from the stash into the release editor, and allow the user
to create a new release.

Requires $c->stash->{release} to be set to the MusicBrainz::Server::Release
to duplicate.

=cut

sub duplicate_release : Private
{
    my ($self, $c) = @_;
    $c->forward('_load_release');

    # Remove IDs from everything - this will force new entities to be created
    my $data = $self->_data($c);
    $data->clear_id;
    $_->clear_id for @{ $data->tracks };
    $_->clear_id for @{ $data->release_events };

    $self->_redirect_to_step($c, 'release_data');
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
        # Setting - copy to session
        $data = shift;
        $c->session->{"release_editor_$index"}->{wizard} = $data->pack;
    }
    else
    {
        # Getting
        if (defined $c->stash->{wizard})
        {
            # We have a wizard, use the current store
            return $c->stash->{wizard}->store;
        }
        else
        {
            # No wizard, restore the store from session (or create a new one)
            my $from_session = $c->session->{"release_editor_$index"}->{wizard};
            return defined $from_session
                ? MusicBrainz::Server::Wizards::ReleaseEditor->unpack($from_session)
                : MusicBrainz::Server::Wizards::ReleaseEditor->new(
                    artist    => $c->stash->{artist}->name,
                    artist_id => $c->stash->{artist}->id,
                );
        }
    }
}

1;
