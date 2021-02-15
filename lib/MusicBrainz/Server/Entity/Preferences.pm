package MusicBrainz::Server::Entity::Preferences;
use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

has 'public_ratings' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'public_subscriptions' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'public_tags' => (
    isa => 'Bool',
    default => 1,
    is => 'rw',
    lazy => 1,
);

has 'datetime_format' => (
    isa => 'Str',
    default => '%Y-%m-%d %H:%M %Z',
    is => 'rw',
    lazy => 1,
);

has 'timezone' => (
    isa => 'Str',
    default => 'UTC',
    is => 'rw',
    lazy => 1,
);

has [qw(email_on_no_vote email_on_notes email_on_vote)] => (
    isa => 'Bool',
    default => 1,
    is =>'rw',
    lazy => 1
);

has [qw( subscribe_to_created_artists
         subscribe_to_created_labels
         subscribe_to_created_series )] => (
    isa => 'Bool',
    default => 1,
    is =>'rw',
    lazy => 1
);

has 'subscriptions_email_period' => (
    isa => 'Str',
    default => 'daily',
    is => 'rw',
    lazy => 1,
);

has 'show_gravatar' => (
    isa => 'Bool',
    default => 0,
    is => 'rw',
    lazy => 1
);

sub TO_JSON {
    my ($self) = @_;

    return {
        datetime_format => $self->datetime_format,
        subscriptions_email_period => $self->subscriptions_email_period,
        timezone => $self->timezone,
        email_on_no_vote => boolean_to_json($self->email_on_no_vote),
        email_on_notes => boolean_to_json($self->email_on_notes),
        email_on_vote => boolean_to_json($self->email_on_vote),
        public_ratings => boolean_to_json($self->public_ratings),
        public_subscriptions => boolean_to_json($self->public_subscriptions),
        public_tags => boolean_to_json($self->public_tags),
        show_gravatar => boolean_to_json($self->show_gravatar),
        subscribe_to_created_artists => boolean_to_json($self->subscribe_to_created_artists),
        subscribe_to_created_labels => boolean_to_json($self->subscribe_to_created_labels),
        subscribe_to_created_series => boolean_to_json($self->subscribe_to_created_series),
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
