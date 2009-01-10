package MusicBrainz::Server::Controller::AddRelease;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Country;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::ReleaseEvent;
use MusicBrainz::Server::Track;

=head2 _current_step

Change the current step of the wizard, but do not cause the wizard to be refreshed

=cut

sub _current_step
{
    my ($self, $c, $new_step) = @_;

    if (defined $new_step) { $c->session->{wizard_step} = $new_step; }
    return $c->session->{wizard_step} || 'add_release_track_count';
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
    $c->detach;
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

    $c->stash->{current_action} = $self->_current_step($c);
    $c->forward($self->_current_step($c));
}

=head2 add_release_track_count

First step in the add release wizard, requesting a track count from the user

=cut

sub add_release_track_count : Form('AddRelease::TrackCount')
{
    my ($self, $c) = @_;

    my $form = $self->form;
    $c->stash->{template} = 'add_release/track_count.tt';

    return unless $c->form_posted &&
                  $form->validate($c->req->params);

    $self->_wizard_data($c)->{track_count} = $form->value('track_count');
    $self->_wizard_data($c)->{event_count} = 1;

    $self->_change_step($c, 'add_release_information');
}

=head2 add_release_information

This step requests information about the release

=cut

sub add_release_information : Form('AddRelease::Tracks')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};

    my $form = $self->form;
    my $w    = $self->_wizard_data($c);

    $form->init($artist);

    my $track_count = $w->{track_count};
    my $event_count = $w->{event_count};

    $c->stash->{track_count} = $track_count;
    $c->stash->{event_count} = $event_count;

    $form->add_tracks($track_count, $artist);
    $form->add_events($event_count);

    $c->stash->{template} = 'add_release/tracks.tt';

    if (!$c->form_posted && scalar keys %{ $w->{release_info} })
    {
        # User has not posted the form on this request, but we
        # do have saved data
        return unless $form->validate($w->{release_info});
    }
    elsif ($c->form_posted)
    {
        # User has posted the form, try and validate
        return unless $form->validate($c->req->params);

        # Store the valid posted data
        $c->req->params->{more_events} = undef; # Bit of a hack...
        $w->{release_info} = $c->req->params;

        if ($form->value('more_events'))
        {
            $c->stash->{event_count} = ++$w->{event_count};

            $form->add_field($form->make_field(
                "event_" . $w->{event_count},
                '+MusicBrainz::Server::Form::Field::ReleaseEvent'
            ));

            return;
        }
    }

    # And wait for the form to be posted...
    return unless $c->form_posted;

    # ----------------

    # If we get here, then the user has submitted the release information
    # form, and the information is valid. Now we need to confirm artists,
    # labels, and check for duplicates

    # If we have no unconfirmed artist data, then let's pre-fill confirmed
    # artists to the artist we are adding a release for (good guess, if the
    # user changes the artist name, they have to reconfirm that artist)
    if (!exists $w->{unconfirmed_artists})
    {
        my $artist = $c->stash->{artist};
        for my $i (1 .. $track_count)
	{
            $w->{confirmed_artists}->{"artist_$i"}->{name} = $artist->name;
            $w->{confirmed_artists}->{"artist_$i"}->{id  } = $artist->id;
	  }
    }

    # Check for any artist names that require reconfirmation
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

    # TODO support multiple release events
    for my $i (1 .. $event_count)
    {
        my $key           = "event_$i.label";
	my $current_value = $w->{release_info}->{$key};

        if ($current_value ne $w->{confirmed_labels}->{$key}->{name})
	{
            $w->{unconfirmed_labels} ||= {};
            $w->{unconfirmed_labels}->{$key} = $current_value;
        }
    }

    # Run this first because it only depends on release title
    # and track count atm
    $self->_change_step($c, 'add_release_check_dupes')
        unless $w->{checked_dupes};

    $self->_change_step($c, 'add_release_confirm_artists')
        if scalar keys %{ $w->{unconfirmed_artists} };

    $self->_change_step($c, 'add_release_confirm_labels')
        if scalar keys %{ $w->{unconfirmed_labels} };

    $self->_change_step($c, 'add_release_confirm')
}

sub add_release_confirm : Form('AddRelease::Tracks')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $w      = $self->_wizard_data($c);

    my $form = $self->form;
    $form->init($artist);

    $form->add_tracks($w->{track_count}, $artist);
    $form->add_events($w->{event_count});
    $form->context($c);

    $c->stash->{template} = 'add_release/confirm.tt';

    return unless $form->validate($w->{release_info});

    # Construct a preview release
    my $preview_release = MusicBrainz::Server::Release->new($c->mb->{dbh});
    $preview_release->name($form->value('title'));

    my @tracks;
    for my $i (1 .. $w->{track_count})
    {
        my $track = MusicBrainz::Server::Track->new($c->mb->{dbh});
        $track->name($form->value("track_$i")->{name});
        $track->sequence($i);
        $track->length($form->value("track_$i")->{duration});
        $track->artist($c->model('Artist')->load($w->{confirmed_artists}->{"artist_$i"}->{id}));

        push @tracks, $track;
    }

    my @events;
    for my $i (1 .. $w->{event_count})
    {
        my $event_hash = $form->value("event_$i") or next;
        my $event      = MusicBrainz::Server::ReleaseEvent->new($c->mb->{dbh});

        my $label_id = $w->{confirmed_labels}->{"event_$i.label"}->{id};
        if ($label_id)
        {
            $event->label($c->model('Label')->load($label_id));
        }

        my $country_id = $event_hash->{country};
        if ($country_id)
        {
            $event->country(MusicBrainz::Server::Country->newFromId($c->mb->{dbh}, $country_id)->name);
        }

        $event->sort_date($event_hash->{date});
        $event->cat_no   ($event_hash->{catalog});
        $event->barcode  ($event_hash->{barcode});
        $event->format   ($event_hash->{format});

        push @events, $event;
    }

    $c->stash->{preview       } = $preview_release;
    $c->stash->{preview_tracks} = \@tracks;
    $c->stash->{preview_events} = \@events;

    return unless $c->form_posted;

    if ($c->req->params->{submit} eq 'Keep Editing')
    {
        $w->{release_info}->{edit_note} = $c->req->params->{edit_note};
        $self->_change_step($c, 'add_release_information');
    }

    my @mods = $form->insert($w->{confirmed_artists}, $w->{confirmed_labels});

    delete $c->session->{wizard};
    delete $c->session->{wizard_step};

    my @add_mods = grep { $_->type eq ModDefs::MOD_ADD_RELEASE } @mods;

    die "Release could not be created"
        unless @add_mods;

    $c->response->redirect($c->uri_for('/release', $add_mods[0]->row_id));
}

sub add_release_confirm_artists : Form('Artist::Create')
{
    my ($self, $c) = @_;

    my $w           = $self->_wizard_data($c);
    my $unconfirmed = $w->{unconfirmed_artists};

    # Do we actually have any artists to confirm?
    $self->_change_step($c, 'add_release_confirm_labels')
        if (scalar keys %$unconfirmed == 0);

    # Choose who to confirm
    my $key = (keys %$unconfirmed)[0];

    # Give them a form to add new artist:
    my $form = $self->form;
    $c->stash->{create_artist} = $form;

    # Forward to do the artist filter
    # TODO Could do with a way to pre-fill the query?
    $c->forward('/search/filter_artist');

    $c->stash->{confirming} = $w->{release_info}->{$key};
    $c->stash->{template  } = 'add_release/confirm_artist.tt';

    return unless $c->form_posted;

    my $artist = $c->stash->{search_result};

    if (!defined $artist)
    {
	# No luck with search, maybe they submitted the create
	# artist form?
	return unless $form->validate($c->req->params);

	# Success!
	$artist = $form->create;
    }

    $w->{confirmed_artists}->{$key}->{name} = $artist->name;
    $w->{confirmed_artists}->{$key}->{id  } = $artist->id;

    $w->{release_info}->{$key} = $artist->name;

    delete $unconfirmed->{$key};
    $self->_change_step($c, 'add_release_confirm_artists');
}

sub add_release_confirm_labels : Form('Label::Create')
{
   my ($self, $c) = @_;

   my $w           = $self->_wizard_data($c);
   my $unconfirmed = $w->{unconfirmed_labels};

   $self->_change_step($c, 'add_release_information')
       if (scalar keys %$unconfirmed == 0);

   my $key = (keys %$unconfirmed)[0];

   $c->forward('/search/filter_label');

   $c->stash->{confirming} = $w->{release_info}->{$key};
   $c->stash->{template  } = 'add_release/confirm_label.tt';

   my $form = $self->form;
   $c->stash->{create_label} = $form;

   return unless $c->form_posted;

   my $label = $c->stash->{search_result};

   if (!defined $label)
   {
	return unless $form->validate($c->req->params);

	$label = $form->create;
   }

   if (defined $label)
   {
        $w->{confirmed_labels}->{$key}->{name} = $label->name;
        $w->{confirmed_labels}->{$key}->{id  } = $label->id;

        $w->{release_info}->{$key} = $label->name;

        delete $unconfirmed->{$key};
        $self->_change_step($c, 'add_release_confirm_labels');
   }
}

sub add_release_check_dupes : Private
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $w      = $self->_wizard_data($c);

    my $similar = $c->model('Release')->find_similar_releases($artist,
                       $w->{release_info}->{title}, $w->{track_count});

    if (scalar @$similar && !$c->form_posted)
    {
        $c->stash->{similar } = [];
	for my $similar (@$similar)
        {
            my $release = $similar;
            $release->LoadFromId;

            push @{ $c->stash->{similar} }, {
                release => $release,
                tracks  => $c->model('Track')->load_from_release($release),
                events  => $c->model('Release')->load_events($release),
            };
        }

	$c->stash->{template} = 'add_release/check_dupes.tt';
    }
    else
    {
        $w->{checked_dupes} = 1;
        $self->_change_step($c, 'add_release_confirm_artists');
    }

}

=head2 restart

Restart the add_release wizard

=cut

sub cancel : Chained('/artist/artist') PathPart('add_release/restart')
{
    my ($self, $c) = @_;

    delete $c->session->{wizard};
    delete $c->session->{wizard_step};

    $c->response->redirect($c->entity_url($c->stash->{artist}, 'show'));
}

1;
