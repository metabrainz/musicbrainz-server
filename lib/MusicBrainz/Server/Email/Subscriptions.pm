package MusicBrainz::Server::Email::Subscriptions;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str );
use MooseX::Types::Structured qw( Map );
use String::TT qw( strip tt );
use MusicBrainz::Server::Entity::Types;

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
    return (
        'Reply-To' => $MusicBrainz::Server::Email::SUPPORT_ADDRESS
    )
}

sub text {
    my $self = shift;
    my @sections;

    push @sections, $self->deleted_subscriptions
        if $self->has_deletes;

    push @sections, $self->edits_for_type(
        'Changes for your subscribed artists',
        @{ $self->edits->{artist} }
    ) if exists $self->edits->{artist};

    push @sections, $self->edits_for_type(
        'Changes for your subscribed labels',
        @{ $self->edits->{label} }
    ) if exists $self->edits->{label};

    push @sections, $self->edits_for_editors(
        @{ $self->edits->{editor} }
    ) if exists $self->edits->{editor};

    return join("\n\n", @sections);
}

sub header {
    my $self = shift;
    return strip tt q{
This is a notification that edits have been added for artists, labels and
editors to whom you subscribed on the MusicBrainz web site.
To view or edit your subscription list, please use the following link:
[% self.server %]/user/[% self.editor.name %]/subscriptions

To see all open edits for your subscriptions, see this link:
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
    my $self = shift;
    my $header = shift;
    my $subs = \@_;
    return strip tt q{
[% header %]
--------------------------------------------------------------------------------
[% FOR sub IN subs %]
[%- artist = sub.subscription.artist -%]
[% artist.name %] [% '(' _ artist.comment _ ') ' IF artist.comment %]([% sub.open.size %] open, [% sub.applied.size %] applied)
[% self.server %]/artist/[% artist.gid %]/edits

[% END %]
};
}

sub edits_for_editors {
    my $self = shift;
    my $subs = \@_;
    return strip tt q{
Changes by your subscribed editors:
--------------------------------------------------------------------------------
[% FOR sub IN subs %]
[%- editor = sub.subscription.subscribed_editor -%]
[% editor.name %] ([% sub.open.size %] open, [% sub.applied.size %] applied)
Open edits: [% self.server %]/user/[% editor.name %]/edits/open
All edits: [% self.server %]/user/[% editor.name %]/edits

[% END %]
};
}

sub deleted_subscriptions {
    my $self = shift;
    return strip tt q{
Deleted and merged artists or labels
--------------------------------------------------------------------------------

Some of your subscribed artists or labels have been merged or deleted:

[% FOR sub IN self.deletes;
edit = sub.deleted_by_edit || sub.merged_by_edit;
type = sub.artist_id ? 'artist' : 'label';
entity_id = sub.artist_id || sub.label_id -%]
[%- type | ucfirst %] #[% entity_id %] - [% sub.deleted_by_edit ? 'deleted' : 'merged' %] by edit #[% edit %]
[% self.server %]/edit/[% edit %]

[% END %]
}
}

1;
