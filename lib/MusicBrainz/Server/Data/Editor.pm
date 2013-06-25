package MusicBrainz::Server::Data::Editor;
use Moose;
use namespace::autoclean;
use LWP;
use URI::Escape;

use Authen::Passphrase;
use Authen::Passphrase::BlowfishCrypt;
use Authen::Passphrase::RejectAll;
use DateTime;
use Digest::MD5 qw( md5_hex );
use Encode;
use Math::Random::Secure qw();
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Entity::Preferences;
use MusicBrainz::Server::Entity::Editor;
use MusicBrainz::Server::Data::Utils qw(
    generate_gid
    hash_to_row
    load_subobjects
    placeholders
    query_to_list
    query_to_list_limited
    query_to_list
    type_to_model
);
use MusicBrainz::Server::Constants qw( :edit_status :privileges );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_editor',
    column => 'subscribed_editor',
    class => 'MusicBrainz::Server::Entity::EditorSubscription'
};

sub _table
{
    return 'editor';
}

sub _columns
{
    return 'editor.id, editor.name, password, privs, email, website, bio,
            member_since, email_confirm_date, last_login_date, edits_accepted,
            edits_rejected, auto_edits_accepted, edits_failed, gender, area,
            birth_date, ha1';
}

sub _column_mapping
{
    return {
        id                      => 'id',
        name                    => 'name',
        email                   => 'email',
        password                => 'password',
        privileges              => 'privs',
        website                 => 'website',
        biography               => 'bio',
        accepted_edits          => 'edits_accepted',
        rejected_edits          => 'edits_rejected',
        failed_edits            => 'edits_failed',
        accepted_auto_edits     => 'auto_edits_accepted',
        email_confirmation_date => 'email_confirm_date',
        registration_date       => 'member_since',
        last_login_date         => 'last_login_date',
        gender_id               => 'gender',
        area_id                 => 'area',
        birth_date              => 'birth_date',
        ha1                     => 'ha1'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Editor';
}

sub get_by_name
{
    my ($self, $name) = @_;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE lower(name) = ? LIMIT 1';
    my $row = $self->sql->select_single_row_hash($query, lc $name);
    my $editor = $self->_new_from_row($row);
    $self->load_preferences($editor);
    return $editor;
}

sub find_by_name
{
    my ($self, $name, $offset, $limit) = @_;
    my $query = 'SELECT ' . $self->_columns .
                '  FROM ' . $self->_table .
                " WHERE musicbrainz_unaccent(lower(name)) LIKE musicbrainz_unaccent(lower(?)) || '%'
                 OFFSET ?";
    my @editors = query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $name, $offset
    );
    $self->load_preferences(@editors);
    return @editors;
}

sub summarize_ratings
{
    my ($self, $user, $me) = @_;

    return {
        map {
            my ($entities) = $self->c->model(type_to_model($_))->rating
                ->find_editor_ratings($user->id, $me, 10, 0);

            ($_ => $entities);
        } qw( artist label recording release_group work)
    };
}

sub _get_tags_for_type
{
    my ($self, $id, $type) = @_;

    my $query = "SELECT tag, count(tag)
        FROM ${type}_tag_raw
        WHERE editor = ?
        GROUP BY tag";

    my $results = $self->c->sql->select_list_of_hashes ($query, $id);

    return { map { $_->{tag} => $_ } @$results };
}

sub get_tags
{
    my ($self, $user) = @_;


    my $tags = {};
    my $max = 0;
    foreach my $entity ('artist', 'label', 'recording', 'release', 'release_group', 'work')
    {
        my $data = $self->_get_tags_for_type ($user->id, $entity);

        foreach (keys %$data)
        {
            if ($tags->{$_})
            {
                $tags->{$_}->{count} += $data->{$_}->{count};
            }
            else
            {
                $tags->{$_} = $data->{$_};
            }

            $max = $tags->{$_}->{count} if $tags->{$_}->{count} > $max;
        }
    }

    my $entities = $self->c->model('Tag')->get_by_ids(keys %$tags);
    foreach (keys %$entities)
    {
        $tags->{$_}->{tag} = $entities->{$_};
    }

    my @tags = sort { $a->{tag}->name cmp $b->{tag}->name } values %$tags;

    return { max => $max, tags => \@tags };
}

around '_get_by_keys' => sub {
    my $orig = shift;
    my $self = shift;

    my $ret = $self->$orig(@_);
    $self->load_preferences(values %$ret);

    return $ret;
};

sub find_by_email
{
    my ($self, $email) = @_;
    return values %{$self->_get_by_keys('email', $email)};
}

sub find_by_privileges
{
    my ($self, $privs) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE (privs & ?) > 0
                 ORDER BY editor.name, editor.id";
    return query_to_list (
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $privs);
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_editor s ON editor.id = s.subscribed_editor
                 WHERE s.editor = ?
                 ORDER BY editor.name, editor.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub find_subscribers
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_editor s ON editor.id = s.editor
                 WHERE s.subscribed_editor = ?
                 ORDER BY editor.name, editor.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub insert
{
    my ($self, $data) = @_;

    $data->{password} = hash_password($data->{password});
    $data->{ha1} = ha1_password($data->{name}, $data->{password});

    return Sql::run_in_transaction(sub {
        return $self->_entity_class->new(
            id => $self->sql->insert_row('editor', $data, 'id'),
            name => $data->{name},
            password => $data->{password},
            ha1 => $data->{ha1},
            accepted_edits => 0,
            rejected_edits => 0,
            failed_edits => 0,
            accepted_auto_edits => 0,
            registration_date => DateTime->now
        );
    }, $self->sql);
}

sub update_email
{
    my ($self, $editor, $email) = @_;

    Sql::run_in_transaction(sub {
        if ($email) {
            my $email_confirmation_date = $self->sql->select_single_value(
                'UPDATE editor SET email=?, email_confirm_date=NOW()
                WHERE id=? RETURNING email_confirm_date', $email, $editor->id);
            $editor->email($email);
            $editor->email_confirmation_date($email_confirmation_date);
        }
        else {
            $self->sql->do('UPDATE editor SET email=NULL, email_confirm_date=NULL
                      WHERE id=?', $editor->id);
            delete $editor->{email};
            delete $editor->{email_confirmation_date};
        }
    }, $self->sql);
}

sub update_password
{
    my ($self, $editor_name, $password) = @_;

    Sql::run_in_transaction(sub {
        $self->sql->do('UPDATE editor SET password = ?, ha1 = md5(name || \':musicbrainz.org:\' || ?), last_login_date = now() WHERE name = ?',
                       hash_password($password),
                       $password,
                       $editor_name);
    }, $self->sql);
}

sub update_profile
{
    my ($self, $editor, $update) = @_;

    my $row = hash_to_row(
        $update,
        {
            bio => 'biography',
            area => 'area_id',
            gender => 'gender_id',
            website => 'website',
            birth_date => 'birth_date',
        }
    );

    if (my $date = delete $row->{birth_date}) {
        if (%$date) { # if date is given but all NULL, it will be an empty hash.
            $row->{birth_date} = sprintf '%d-%d-%d', map { $date->{$_} } qw( year month day )
        }
        else {
            $row->{birth_date} = undef;
        }
    }

    Sql::run_in_transaction(sub {
        $self->sql->update_row('editor', $row, { id => $editor->id });
    }, $self->sql);
}

sub update_privileges
{
    my ($self, $editor, $values) = @_;

    my $privs =   $values->{auto_editor}      * $AUTO_EDITOR_FLAG
                + $values->{bot}              * $BOT_FLAG
                + $values->{untrusted}        * $UNTRUSTED_FLAG
                + $values->{link_editor}      * $RELATIONSHIP_EDITOR_FLAG
                + $values->{location_editor}  * $LOCATION_EDITOR_FLAG
                + $values->{no_nag}           * $DONT_NAG_FLAG
                + $values->{wiki_transcluder} * $WIKI_TRANSCLUSION_FLAG
                + $values->{mbid_submitter}   * $MBID_SUBMITTER_FLAG
                + $values->{account_admin}    * $ACCOUNT_ADMIN_FLAG;

    Sql::run_in_transaction(sub {
        $self->sql->do('UPDATE editor SET privs=? WHERE id=?',
                 $privs, $editor->id);
    }, $self->sql);
}

sub make_autoeditor
{
    my ($self, $editor_id) = @_;

    $self->sql->do('UPDATE editor SET privs = privs | ? WHERE id = ?',
                   $AUTO_EDITOR_FLAG, $editor_id);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'editor', @objs);
    $self->load_preferences(map { $_->editor } grep defined, @objs);
}

sub load_preferences
{
    my ($self, @editors) = @_;

    return unless @editors;

    my %editors = map { $_->id => $_ } grep { defined } @editors
        or return;

    my $query = sprintf "SELECT editor, name, value ".
        "FROM editor_preference WHERE editor IN (%s)",
        placeholders(keys %editors);

    my $prefs = $self->sql->select_list_of_hashes($query, keys %editors);

    for my $pref (@$prefs) {
        my ($editor_id, $key, $value) = ($pref->{editor}, $pref->{name}, $pref->{value});
        next unless $editors{$editor_id}->preferences->can($key);
        $editors{$editor_id}->preferences->$key($value);
    }
}

sub save_preferences
{
    my ($self, $editor, $values) = @_;

    Sql::run_in_transaction(sub {

        $self->sql->do('DELETE FROM editor_preference WHERE editor = ?', $editor->id);
        my $preferences_meta = $editor->preferences->meta;
        foreach my $name (keys %$values) {
            my $default = $preferences_meta->get_attribute($name)->default;
            unless ($default eq $values->{$name}) {
                $self->sql->insert_row('editor_preference', {
                    editor => $editor->id,
                    name   => $name,
                    value  => $values->{$name},
                });
            }
        }
        $editor->preferences(MusicBrainz::Server::Entity::Preferences->new(%$values));

    }, $self->sql);
}

sub credit
{
    my ($self, $editor_id, $status, %opts) = @_;
    my $column;
    my $as_autoedit = $opts{auto_edit} ? 1 : 0;
    return if $status == $STATUS_DELETED;
    $column = "edits_rejected" if $status == $STATUS_FAILEDVOTE;
    $column = "edits_accepted" if $status == $STATUS_APPLIED && !$as_autoedit;
    $column = "auto_edits_accepted" if $status == $STATUS_APPLIED && $as_autoedit;
    $column ||= "edits_failed";
    my $query = "UPDATE editor SET $column = $column + 1 WHERE id = ?";
    $self->sql->do($query, $editor_id);
}

# Must be run in a transaction to actually do anything. Acquires a row-level lock for a given editor ID.
sub lock_row
{
    my ($self, $editor_id) = @_;
    my $query = "SELECT 1 FROM " . $self->_table . " WHERE id = ? FOR UPDATE";
    $self->sql->do($query, $editor_id);
}

sub donation_check
{
    my ($self, $obj) = @_;

    my $nag = 1;
    $nag = 0 if ($obj->is_nag_free || $obj->is_auto_editor || $obj->is_bot ||
                 $obj->is_relationship_editor || $obj->is_wiki_transcluder ||
                 $obj->is_location_editor);

    my $days = 0.0;
    if ($nag)
    {
        my $ua = LWP::UserAgent->new;
        $ua->agent("MusicBrainz server");
        $ua->timeout(5); # in seconds.

        my $response = $ua->request(HTTP::Request->new (GET =>
            'http://metabrainz.org/donations/nag-check/' .
            uri_escape_utf8($obj->name)));

        if ($response->is_success && $response->content =~ /\s*([-01]+),([-0-9.]+)\s*/)
        {
            $nag = $1;
            $days = $2;
        }
        else
        {
            return undef;
        }
    }

    return { nag => $nag, days => $days };
}

sub editors_with_subscriptions
{
    my ($self) = @_;

    my @tables = qw(
        editor_subscribe_artist
        editor_subscribe_collection
        editor_subscribe_editor
        editor_subscribe_label
    );
    my $ids = join(' UNION ALL ', map { "SELECT editor FROM $_" } @tables);
    my $query = "SELECT " . $self->_columns . ", ep.value AS prefs_value
                   FROM " . $self->_table . "
              LEFT JOIN editor_preference ep
                     ON ep.editor = editor.id AND
                        ep.name = 'subscriptions_email_period'
                  WHERE editor.id IN ($ids)";

    return query_to_list (
        $self->c->sql, sub {
            my $editor = $self->_new_from_row(@_);
            $editor->preferences->subscriptions_email_period($_[0]->{prefs_value})
                if defined $_[0]->{prefs_value};
            return $editor;
        },
        $query);
}

sub delete {
    my ($self, $editor_id) = @_;
    die "Invalid editor_id: $editor_id" unless $editor_id > 0;

    $self->sql->begin;
    $self->sql->do(
        "UPDATE editor SET name = 'Deleted Editor #' || id,
                           password = ?,
                           ha1 = '',
                           privs = 0,
                           email = NULL,
                           email_confirm_date = NULL,
                           website = NULL,
                           bio = NULL,
                           area = NULL,
                           birth_date = NULL,
                           gender = NULL
         WHERE id = ?",
        Authen::Passphrase::RejectAll->new->as_rfc2307,
        $editor_id
    );

    $self->sql->do("DELETE FROM editor_preference WHERE editor = ?", $editor_id);
    $self->c->model('EditorLanguage')->delete_editor($editor_id);
    $self->c->model('EditorOAuthToken')->delete_editor($editor_id);

    $self->c->model('EditorSubscriptions')->delete_editor($editor_id);
    $self->c->model('Editor')->unsubscribe_to($editor_id);
    $self->c->model('Collection')->delete_editor($editor_id);
    $self->c->model('WatchArtist')->delete_editor($editor_id);

    $self->c->model($_)->tags->clear($editor_id)
        for qw( Artist
                Label
                Recording
                Release
                ReleaseGroup
                Work
          );

    $self->c->model($_)->rating->clear($editor_id)
        for qw( Artist
                Label
                Recording
                ReleaseGroup
                Work
          );

    # Cancel any open edits the editor still has
    my @edits = values %{ $self->c->model('Edit')->get_by_ids(
        @{ $self->sql->select_single_column_array(
            'SELECT id FROM edit WHERE editor = ? AND status = ?',
            $editor_id, $STATUS_OPEN)
       }
    ) };

    for my $edit (@edits) {
        $self->c->model('Edit')->cancel($edit);
    }

    $self->sql->commit;
}

sub subscription_summary {
    my ($self, $editor_id) = @_;

    $self->sql->select_single_row_hash(
        'SELECT ' .
            join(', ', map {
                "COALESCE(
                   (SELECT count(*) FROM editor_subscribe_$_ WHERE editor = ?),
                   0) AS $_"
            } qw( artist collection label editor )),
        ($editor_id) x 4
    );
}

sub open_edit_count
{
    my ($self, $editor_id) = @_;
    my $query =
        'SELECT count(*)
           FROM edit
          WHERE status = ?
          AND editor = ?
       ';

    return $self->sql->select_single_value($query, $STATUS_OPEN, $editor_id);
}

sub last_24h_edit_count
{
    my ($self, $editor_id) = @_;
    my $query =
        "SELECT count(*)
           FROM edit
          WHERE editor = ?
          AND open_time >= (now() - interval '1 day')
       ";

    return $self->sql->select_single_value($query, $editor_id);
}

sub unsubscribe_to {
    my ($self, $editor_id) = @_;
    $self->sql->do(
        'DELETE FROM editor_subscribe_editor WHERE subscribed_editor = ?',
        $editor_id);
}

sub update_last_login_date {
    my ($self, $editor_id) = @_;
    $self->sql->auto_commit(1);
    $self->sql->do('UPDATE editor SET last_login_date = now() WHERE id = ?', $editor_id);
}

sub hash_password {
    my $password = shift;
    Authen::Passphrase::BlowfishCrypt->new(
        salt_random => 1,
        cost => 10,
        passphrase => encode('utf-8', $password)
    )->as_rfc2307
}

sub ha1_password {
    my ($username, $password) = @_;
    return md5_hex(join(':', $username, 'musicbrainz.org', $password));
}

sub consume_remember_me_token {
    my ($self, $user_name, $token) = @_;

    my $token_key = "$user_name|$token";
    # Expire consumed tokens in 5 minutes. This allows the case where the user
    # has no session, and opens multiple tabs using the same remember_me token.
    $self->redis->expire($token_key, 5 * 60);
    $self->redis->exists($token_key);
}

sub allocate_remember_me_token {
    my ($self, $user_name) = @_;

    if (
        $self->sql->select_single_value(
            'SELECT TRUE FROM editor WHERE name = ?',
            $user_name
        )
    ) {
        # Generate a 128-bit token. irand is 32-bit.
        my $token = join('', map { '' . Math::Random::Secure::irand() } (0 .. 3));

        my $key = "$user_name|$token";
        $self->redis->add($key, 1);

        # Expire tokens after 1 year.
        $self->redis->expire($key, 60 * 60 * 24 * 7 * 52);

        return $token;
    }
    else {
        return undef;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Editor - database level loading support for
Editors

=head1 DESCRIPTION

Provides support for fetching editors from the database

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

