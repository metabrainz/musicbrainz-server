package MusicBrainz::Server::Email::Subscriptions;
use Moose;
use namespace::autoclean;

use List::UtilsBy qw( sort_by );
use MooseX::Types::Moose qw( ArrayRef Str );
use MooseX::Types::Structured qw( Map );
use String::TT qw( strip tt );
use URI::Escape;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( $EMAIL_SUPPORT_ADDRESS );
use MusicBrainz::Server::Email;

has 'editor' => (
    isa => 'Editor',
    required => 1,
    is => 'ro',
);

has 'to' => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->editor->email }
);

with 'MusicBrainz::Server::Email::Role';

sub subject { 'Edits for your subscriptions' }

has 'deletes' => (
    isa => ArrayRef,
    is => 'ro',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        has_deletes => 'count',
    }
);

has 'edits' => (
    isa => Map[Str, ArrayRef],
    is => 'ro',
    default => sub { {} }
);

sub extra_headers {
    my $self = shift;
    return (
        'Reply-To' => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => MusicBrainz::Server::Email::_message_id('subscriptions-%s-%d', $self->editor->id, time())
    )
}

sub text {
    my $self = shift;
    my @sections;

    push @sections, $self->deleted_subscriptions
        if $self->has_deletes;

    push @sections, $self->edits_for_type(
        'Changes for your subscribed artists',
        [ sort_by { $_->{subscription}->artist->sort_name } @{ $self->edits->{artist} } ],
        'artist'
    ) if exists $self->edits->{artist};

    push @sections, $self->edits_for_type(
        'Changes for your subscribed collections',
        [ sort_by { $_->{subscription}->collection->name } @{ $self->edits->{collection} } ],
        'collection'
    ) if exists $self->edits->{collection};

    push @sections, $self->edits_for_type(
        'Changes for your subscribed labels',
        [ sort_by { $_->{subscription}->label->sort_name } @{ $self->edits->{label} } ],
        'label'
    ) if exists $self->edits->{label};

    push @sections, $self->edits_for_editors(
        sort_by { $_->{subscription}->subscribed_editor->name } @{ $self->edits->{editor} }
    ) if exists $self->edits->{editor};

    return join("\n\n", @sections);
}

sub header {
    my $self = shift;
    my $escape = sub { uri_escape_utf8(shift) };
    return strip tt q{
This is a notification that edits have been added for artists, labels,
collections and editors to whom you subscribed on the MusicBrainz web site.
To view or edit your subscription list, please use the following link:
[% self.server %]/user/[% escape(self.editor.name) %]/subscriptions

To see all open edits for your subscribed entities, see this link:
[% self.server %]/edit/subscribed
};
}

sub footer {
    my $self = shift;
    return strip tt q{
Please do not reply to this message.  If you need help, please see
[% self.server %]/doc/ContactUs
};
}

sub edits_for_type {
    my ($self, $header, $subs, $type) = @_;
    my $get_entity = sub { shift->$type };

    return strip tt q{
[% header %]
--------------------------------------------------------------------------------
[% FOR sub IN subs %]
[%- entity = get_entity(sub.subscription) -%]
[% entity.name %] [% '(' _ entity.comment _ ') ' IF entity.comment %]([% sub.open.size %] open, [% sub.applied.size %] applied)
[% self.server %]/[% type %]/[% entity.gid %]/edits

[% END %]
};
}

sub edits_for_editors {
    my $self = shift;
    my $subs = \@_;

    my $escape = sub { uri_escape_utf8(shift) };
    return strip tt q{
Changes by your subscribed editors:
--------------------------------------------------------------------------------
[% FOR sub IN subs %]
[%- editor = sub.subscription.subscribed_editor -%]
[% editor.name %] ([% sub.open.size %] open, [% sub.applied.size %] applied)
Open edits: [% self.server %]/user/[% escape(editor.name) %]/edits/open
All edits: [% self.server %]/user/[% escape(editor.name) %]/edits

[% END %]
};
}

sub deleted_subscriptions {
    my $self = shift;
    return strip tt q{
Deleted and merged artists or labels
--------------------------------------------------------------------------------

Some of your subscribed artists, labels or collections have been merged,
deleted or made private:

[% FOR sub IN self.deletes;
edit = sub.edit_id;
type = sub.isa('MusicBrainz::Server::Entity::Subscription::DeletedArtist') ? 'artist'
     : sub.isa('MusicBrainz::Server::Entity::Subscription::DeletedLabel') ? 'label'
     : sub.isa('MusicBrainz::Server::Entity::CollectionSubscription') ? 'collection'
     : 'unknown';  -%]
[%- IF type == 'collection' -%]
[%- type | ucfirst %] "[% sub.last_seen_name %]" - deleted or made private
[% ELSE -%]
[%- type | ucfirst %] "[% sub.last_known_name %]"[% '(' _ sub.last_known_comment _ ') ' IF sub.last_known_comment %] - [% sub.reason %] by edit #[% edit %]
[% self.server %]/edit/[% edit %]
[% END -%]
[%- END %]
}
}

1;
