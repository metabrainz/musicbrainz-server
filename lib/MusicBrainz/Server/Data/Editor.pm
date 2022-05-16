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
use MusicBrainz::Server::Constants qw( :edit_status entities_with );
use MusicBrainz::Server::Entity::Preferences;
use MusicBrainz::Server::Entity::Editor;
use MusicBrainz::Server::Data::Utils qw(
    generate_token
    hash_to_row
    load_subobjects
    placeholders
    type_to_model
);
use MusicBrainz::Server::Constants qw( :edit_status :privileges );
use MusicBrainz::Server::Constants qw( $PASSPHRASE_BCRYPT_COST );
use MusicBrainz::Server::Constants qw( :create_entity $EDIT_HISTORIC_ADD_RELEASE );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_COVER_ART );
use MusicBrainz::Server::Constants qw( :vote );

extends 'MusicBrainz::Server::Data::Entity';

with 'MusicBrainz::Server::Data::Role::Area';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_editor',
    column => 'subscribed_editor',
    active_class => 'MusicBrainz::Server::Entity::EditorSubscription'
};

sub _table
{
    return 'editor';
}

sub _columns
{
    return 'editor.id, editor.name COLLATE musicbrainz, password, privs, email, website, bio,
            member_since, email_confirm_date, last_login_date,
            EXISTS (SELECT 1 FROM edit WHERE edit.editor = editor.id AND edit.autoedit = 0 AND edit.status = ' . $STATUS_APPLIED . ' OFFSET 9) AS has_ten_accepted_edits,
            gender, area,
            birth_date, ha1, deleted';
}

sub _area_columns { [qw( area )] }

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
        has_ten_accepted_edits  => 'has_ten_accepted_edits',
        email_confirmation_date => 'email_confirm_date',
        registration_date       => 'member_since',
        last_login_date         => 'last_login_date',
        gender_id               => 'gender',
        area_id                 => 'area',
        birth_date              => 'birth_date',
        ha1                     => 'ha1',
        deleted                 => 'deleted',
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
                ' WHERE lower(name) = lower(?) LIMIT 1';
    my $row = $self->sql->select_single_row_hash($query, $name);
    my $editor = $self->_new_from_row($row);
    $self->load_preferences($editor);
    return $editor;
}

sub summarize_ratings
{
    my ($self, $user, $me) = @_;

    return {
        map {
            my ($entities) = $self->c->model(type_to_model($_))->rating
                ->find_editor_ratings($user->id, $me, 10, 0);

            ($_ => $entities);
        } entities_with('ratings')
    };
}

sub _get_tags_for_type
{
    my ($self, $id, $type, $show_downvoted) = @_;

    my $is_upvote = $show_downvoted ? 0 : 1;

    my $query = "SELECT tag, count(tag)
        FROM ${type}_tag_raw
        WHERE editor = ? AND is_upvote = ?
        GROUP BY tag";

    my $results = $self->c->sql->select_list_of_hashes($query, $id, $is_upvote);

    return { map { $_->{tag} => $_ } @$results };
}

sub get_tags
{
    my ($self, $user, $show_downvoted, $order) = @_;


    my $tags = {};
    my $max = 0;
    foreach my $entity (entities_with('tags'))
    {
        my $data = $self->_get_tags_for_type($user->id, $entity, $show_downvoted);

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

    my @tags;
    $order //= '';
    if ($order eq 'count') {
        @tags = sort { $b->{count} <=> $a->{count} } values %$tags;
    } elsif ($order eq 'countdesc') {
        @tags = sort { $a->{count} <=> $b->{count} } values %$tags;
    } else {
        @tags = sort { $a->{tag}->name cmp $b->{tag}->name } values %$tags;
    }

    return { max => $max, tags => \@tags };
}

around '_get_by_keys' => sub {
    my $orig = shift;
    my $self = shift;

    my @ret = $self->$orig(@_);
    $self->load_preferences(@ret);

    return @ret;
};

sub find_by_email
{
    my ($self, $email) = @_;
    return $self->_get_by_keys('email', $email);
}

sub find_by_ip {
    my ($self, $ip) = @_;

    my $query = 'SELECT ' . $self->_columns .
        ' FROM ' . $self->_table . ' WHERE id = any(?)' .
        ' ORDER BY member_since LIMIT 100';

    my @ids = $self->store->set_members("ipusers:$ip");
    $self->query_to_list($query, [\@ids]);
}

sub search_by_email {
    my ($self, $email_regexp) = @_;

    my $query = 'SELECT ' . $self->_columns .
        ' FROM ' . $self->_table .
        q" WHERE (regexp_replace(regexp_replace(email, '[@+].*', ''), '\.', '', 'g') || regexp_replace(email, '.*@', '@')) ~ ?" .
        ' ORDER BY member_since DESC LIMIT 100';

    $self->query_to_list($query, [$email_regexp]);
}

sub find_by_privileges
{
    my ($self, $privs, $exact_only, $limit, $offset) = @_;

    my $condition;
    my $args;
    if ($exact_only) {
        $condition = 'privs = ?';
        $args = [$privs];
    } else {
        $condition = '(privs & ?) = ?';
        $args = [($privs) x 2];
    }

    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . "
                 WHERE $condition
                 ORDER BY editor.name, editor.id";
    $self->query_to_list_limited($query, $args, $limit, $offset);
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN editor_subscribe_editor s ON editor.id = s.subscribed_editor
                 WHERE s.editor = ?
                 ORDER BY editor.name, editor.id';
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub find_subscribers
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN editor_subscribe_editor s ON editor.id = s.editor
                 WHERE s.subscribed_editor = ?
                 ORDER BY editor.name, editor.id';
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub insert
{
    my ($self, $data) = @_;

    die 'Invalid user name' if $data->{name} =~ qr{^deleted editor \#\d+$}i;
    my $plaintext = $data->{password};
    $data->{password} = hash_password($plaintext);
    $data->{ha1} = ha1_password($data->{name}, $plaintext);

    return Sql::run_in_transaction(sub {
        return $self->_entity_class->new(
            id => $self->sql->insert_row('editor', $data, 'id'),
            name => $data->{name},
            password => $data->{password},
            ha1 => $data->{ha1},
            registration_date => DateTime->now
        );
    }, $self->sql);
}

sub search_old_editor_names {
    my ($self, $name, $use_regular_expression) = @_;

    my $condition = $use_regular_expression ? 'name ~* ?' : 'LOWER(name) = LOWER(?)';
    my $query = "SELECT name FROM old_editor_name WHERE $condition LIMIT 100";

    @{ $self->sql->select_single_column_array($query, $name) };
}

sub unlock_old_editor_name {
    my ($self, $name) = @_;

    my $query = 'DELETE FROM old_editor_name WHERE name = ?';

    $self->sql->do($query, $name);
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
        $self->sql->do(<<~'SQL', hash_password($password), $password, $editor_name);
            UPDATE editor
            SET password = ?, ha1 = md5(name || ':musicbrainz.org:' || ?), 
                last_login_date = now()
            WHERE lower(name) = lower(?)
            SQL
    }, $self->sql);
}

sub update_profile
{
    my ($self, $editor, $update) = @_;

    my $row = hash_to_row(
        $update,
        {
            name => 'username',
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

sub update_privileges {
    my ($self, $editor, $values) = @_;

    # Setting Spammer should also block editing and notes
    $values->{editing_disabled} ||= $values->{spammer};
    $values->{adding_notes_disabled} ||= $values->{spammer};

    my $privs =   ($values->{auto_editor}           // 0) * $AUTO_EDITOR_FLAG
                + ($values->{bot}                   // 0) * $BOT_FLAG
                + ($values->{untrusted}             // 0) * $UNTRUSTED_FLAG
                + ($values->{link_editor}           // 0) * $RELATIONSHIP_EDITOR_FLAG
                + ($values->{location_editor}       // 0) * $LOCATION_EDITOR_FLAG
                + ($values->{no_nag}                // 0) * $DONT_NAG_FLAG
                + ($values->{wiki_transcluder}      // 0) * $WIKI_TRANSCLUSION_FLAG
                + ($values->{banner_editor}         // 0) * $BANNER_EDITOR_FLAG
                + ($values->{mbid_submitter}        // 0) * $MBID_SUBMITTER_FLAG
                + ($values->{account_admin}         // 0) * $ACCOUNT_ADMIN_FLAG
                + ($values->{editing_disabled}      // 0) * $EDITING_DISABLED_FLAG
                + ($values->{adding_notes_disabled} // 0) * $ADDING_NOTES_DISABLED_FLAG
                + ($values->{spammer}               // 0) * $SPAMMER_FLAG;

    Sql::run_in_transaction(sub {
        $self->sql->do('UPDATE editor SET privs = ? WHERE id = ?', $privs, $editor->id);
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

    my $query = sprintf 'SELECT editor, name, value '.
        'FROM editor_preference WHERE editor IN (%s)',
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

sub donation_check
{
    my ($self, $obj) = @_;

    my $nag = 1;
    $nag = 0 if ($obj->is_nag_free || $obj->is_auto_editor || $obj->is_bot ||
                 $obj->is_relationship_editor || $obj->is_wiki_transcluder ||
                 $obj->is_location_editor);

    my $days = 0.0;
    if ($nag) {
        my $response = $self->c->lwp->get(
            'https://metabrainz.org/donations/nag-check?editor=' . uri_escape_utf8($obj->name)
        );

        if ($response->is_success && $response->content =~ /\s*([-01]+),([-0-9.]+)\s*/) {
            # Possible values for nag will be -1, 0, 1 (only 0 means do not nag)
            $nag = $1;
            $days = $2;
        } else {
            return undef;
        }
    }

    return { nag => $nag, days => $days };
}

sub load_for_collection {
    my ($self, $collection) = @_;

    my $id = $collection->{id};
    return unless $id; # nothing to do

    $self->load($collection);
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . "
                 JOIN editor_collection_collaborator ecc ON editor.id = ecc.editor
                 WHERE ecc.collection = $id
                 ORDER BY editor.name, editor.id";
    my @collaborators = $self->query_to_list($query);

    $collection->collaborators(\@collaborators);
}

sub editors_with_subscriptions {
    my ($self, $after, $limit) = @_;

    my @tables = (entities_with('subscriptions',
                                take => sub { return 'editor_subscribe_' . (shift) }),
                  entities_with(['subscriptions', 'deleted'],
                                take => sub { return 'editor_subscribe_' . (shift) . '_deleted' }));
    my $ids = join(' UNION ALL ', map { "SELECT editor FROM $_" } @tables);
    my $query = 'SELECT ' . $self->_columns . ', ep.value AS prefs_value
                   FROM ' . $self->_table . "
              LEFT JOIN editor_preference ep
                     ON ep.editor = editor.id AND
                        ep.name = 'subscriptions_email_period'
                  WHERE editor.id > ?
                    AND editor.id IN ($ids)
               ORDER BY editor.id ASC
                  LIMIT ?";

    $self->query_to_list($query, [$after, $limit], sub {
        my ($model, $row) = @_;

        my $editor = $model->_new_from_row($row);
        $editor->preferences->subscriptions_email_period($row->{prefs_value})
            if defined $row->{prefs_value};
        $editor;
    });
}

sub delete {
    my ($self, $editor_id, $allow_reuse) = @_;
    die "Invalid editor_id: $editor_id" unless $editor_id > 0;
    my $editor = $self->c->model('Editor')->get_by_id($editor_id);

    $self->sql->begin;
    $self->sql->do(
        'INSERT INTO old_editor_name (name)
         (SELECT name FROM editor WHERE id = ?)',
        $editor_id,
    ) unless $allow_reuse;
    $self->sql->do(
        q{UPDATE editor SET name = 'Deleted Editor #' || id,
                           password = ?,
                           ha1 = '',
                           privs = 0,
                           email = NULL,
                           email_confirm_date = NULL,
                           website = NULL,
                           bio = NULL,
                           area = NULL,
                           birth_date = NULL,
                           gender = NULL,
                           deleted = TRUE
         WHERE id = ?},
        Authen::Passphrase::RejectAll->new->as_rfc2307,
        $editor_id
    );

    $self->sql->do('DELETE FROM editor_preference WHERE editor = ?', $editor_id);
    $self->c->model('EditorLanguage')->delete_editor($editor_id);

    $self->c->model('EditorOAuthToken')->delete_editor($editor_id);
    $self->c->model('Application')->delete_editor($editor_id);

    $self->c->model('EditorSubscriptions')->delete_editor($editor_id);
    $self->c->model('Editor')->unsubscribe_to($editor_id);
    $self->c->model('Collection')->delete_editor($editor_id);
    $self->c->model('WatchArtist')->delete_editor($editor_id);

    $self->c->model($_)->tags->clear($editor_id)
        for (entities_with('tags', take => 'model'));

    $self->c->model($_)->rating->clear($editor_id)
        for (entities_with('ratings', take => 'model'));

    # Cancel any open edits the editor still has
    # We want to cancel the latest edits first, to make sure
    # no conflicts happen that make some cancelling fail and all
    # entities that should be autoremoved do get removed
    my $own_edit_ids = $self->sql->select_single_column_array(
            'SELECT id FROM edit WHERE editor = ? AND status = ? ORDER BY open_time DESC',
            $editor_id, $STATUS_OPEN);
    my $own_edits = $self->c->model('Edit')->get_by_ids(@$own_edit_ids);

    for my $edit_id (@$own_edit_ids) {
        $self->c->model('Edit')->cancel($own_edits->{$edit_id});
    }

    # Override any Yes/No votes on open edits with Abstain
    # to avoid pre-deletion vandalism
    my $voted_open_edit_ids = $self->sql->select_single_column_array(
            'SELECT edit.id
             FROM edit
             JOIN vote
               ON edit.id = vote.edit
             WHERE edit.status = ?
               AND vote.editor = ?
               AND vote.vote IN (?, ?)
               AND vote.superseded = FALSE
            ORDER BY open_time DESC',
            $STATUS_OPEN, $editor_id, $VOTE_YES, $VOTE_NO);

    for my $edit_id (@$voted_open_edit_ids) {
        $self->c->model('Vote')->enter_votes(
            $editor,
            {
                vote    => $VOTE_ABSTAIN,
                edit_id => $edit_id
            }
        );
    }

    # Delete completely if they're not actually referred to by anything
    # These AND NOT EXISTS clauses are ordered by likelihood of a row existing
    # and whether or not they have an index to use, as postgresql will not execute
    # the later clauses if an earlier one has already excluded the lone editor row.
    my $should_delete = $self->sql->select_single_value(
        'SELECT TRUE FROM editor WHERE id = ?
         AND NOT EXISTS (SELECT TRUE FROM edit WHERE editor = editor.id)
         AND NOT EXISTS (SELECT TRUE FROM edit_note WHERE editor = editor.id)
         AND NOT EXISTS (SELECT TRUE FROM vote WHERE editor = editor.id)
         AND NOT EXISTS (SELECT TRUE FROM annotation WHERE editor = editor.id)
         AND NOT EXISTS (SELECT TRUE FROM autoeditor_election_vote WHERE voter = editor.id)
         AND NOT EXISTS (SELECT TRUE FROM autoeditor_election WHERE candidate = editor.id OR proposer = editor.id OR seconder_1 = editor.id OR seconder_2 = editor.id)',
        $editor_id);
    if ($should_delete) {
        $self->sql->do('DELETE FROM editor WHERE id = ?', $editor_id);
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
            } entities_with('subscriptions')),
        ($editor_id) x 5
    );
}

sub various_edit_counts {
    my ($self, $editor_id) = @_;
    my %result = map { $_ . '_count' => 0 }
        qw( accepted accepted_auto rejected cancelled open failed );

    my $query =
        q{SELECT
              CASE
                WHEN status = ? THEN
                  CASE
                    WHEN autoedit = 0 THEN 'accepted'
                    ELSE 'accepted_auto'
                  END
                WHEN status = ? THEN 'rejected'
                WHEN status = ? THEN 'cancelled'
                WHEN status = ? THEN 'open'
                ELSE 'failed'
              END AS category,
              COUNT(*) AS count
            FROM edit
           WHERE editor = ?
           GROUP BY category};
    my @params = ($STATUS_APPLIED, $STATUS_FAILEDVOTE, $STATUS_DELETED, $STATUS_OPEN);
    my $rows = $self->sql->select_list_of_lists($query, @params, $editor_id);

    for my $row (@$rows) {
        my ($category, $count) = @$row;
        $result{$category . '_count'} = $count;
    }
    return \%result;
}

sub added_entities_counts {
    my ($self, $editor_id) = @_;

    my $cache_key = "editor:$editor_id:added_entities_counts";
    my $cached_result = $self->c->cache->get($cache_key);
    return $cached_result if defined $cached_result;

    my %result = map { $_ => 0 }
        qw( artist release area cover_art event instrument label place recording
        releasegroup series work other );

    my $query =
        q{SELECT
              CASE
                WHEN type = ? THEN 'artist'
                WHEN type IN (?, ?) THEN 'release'
                WHEN type = ? THEN 'area'
                WHEN type = ? THEN 'cover_art'
                WHEN type = ? THEN 'event'
                WHEN type = ? THEN 'instrument'
                WHEN type = ? THEN 'label'
                WHEN type = ? THEN 'place'
                WHEN type = ? THEN 'recording'
                WHEN type = ? THEN 'releasegroup'
                WHEN type = ? THEN 'series'
                WHEN type = ? THEN 'work'
                ELSE 'other'
              END AS type,
              COUNT(*) AS count
            FROM edit
           WHERE edit.status = ?
             AND editor = ?
           GROUP BY type};
    my @params = ($EDIT_ARTIST_CREATE, $EDIT_RELEASE_CREATE,
        $EDIT_HISTORIC_ADD_RELEASE, $EDIT_AREA_CREATE, $EDIT_RELEASE_ADD_COVER_ART,
        $EDIT_EVENT_CREATE, $EDIT_INSTRUMENT_CREATE, $EDIT_LABEL_CREATE,
        $EDIT_PLACE_CREATE, $EDIT_RECORDING_CREATE, $EDIT_RELEASEGROUP_CREATE,
        $EDIT_SERIES_CREATE, $EDIT_WORK_CREATE, $STATUS_APPLIED);
    my $rows = $self->sql->select_list_of_lists($query, @params, $editor_id);

    for my $row (@$rows) {
        my ($type, $count) = @$row;
        # We just ignore any edits that are not one of the desired types
        if ($type ne 'other') {
            if (defined $result{$type}) {
                $result{$type} += $count;
            } else {
                $result{$type} = $count;
            }
        }
    }

    $self->c->cache->set($cache_key, \%result, 60 * 60 * 24);

    return \%result;
}

sub secondary_counts {
    my ($self, $editor_id, $viewing_own_profile) = @_;

    my $editor = $self->get_by_id($editor_id);
    $self->load_preferences($editor);

    my %result;

    if ($viewing_own_profile || $editor->preferences->public_tags) {
        $result{upvoted_tag_count} = 0;
        $result{downvoted_tag_count} = 0;

        my @tag_tables = entities_with(
            'tags',
            take => sub { shift . '_tag_raw' },
        );
        my $tag_inner_query = join(
            ' UNION ALL ',
            map { "SELECT is_upvote FROM $_ WHERE editor = ?" } @tag_tables
        );

        my $query = <<~SQL;
            SELECT x.is_upvote, count(*)
            FROM ($tag_inner_query) x
            GROUP BY x.is_upvote
            SQL

        my $rows = $self->sql->select_list_of_lists(
            $query,
            ($editor_id) x scalar @tag_tables,
        );

        for my $row (@$rows) {
            my ($is_upvote, $count) = @$row;
            if ($is_upvote) {
                $result{upvoted_tag_count} = $count + 0;
            } else {
                $result{downvoted_tag_count} = $count + 0;
            }
        }
  }

    if ($viewing_own_profile || $editor->preferences->public_ratings) {
        my @rating_tables = entities_with(
            'ratings',
            take => sub { shift . '_rating_raw' },
        );
        my $rating_inner_query = join(
            ' UNION ALL ',
            map { "SELECT 1 FROM $_ WHERE editor = ?" } @rating_tables
        );

        my $query = "SELECT count(*) FROM ($rating_inner_query) x";

        $result{rating_count} = $self->sql->select_single_value(
            $query,
            ($editor_id) x scalar @rating_tables,
        );
    }

    return \%result;
}

sub last_24h_edit_count
{
    my ($self, $editor_id) = @_;

    my $query =
        q{SELECT count(*)
           FROM edit
          WHERE editor = ?
          AND open_time >= (now() - interval '1 day')};

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
        cost => $PASSPHRASE_BCRYPT_COST,
        passphrase => encode('utf-8', $password),
    )->as_rfc2307
}

sub ha1_password {
    my ($username, $password) = @_;
    return md5_hex(join(':', encode('utf-8', $username), 'musicbrainz.org', encode('utf-8', $password)));
}

sub consume_remember_me_token {
    my ($self, $user_name, $token) = @_;

    my $token_key = "$user_name|$token";
    # Expire consumed tokens in 5 minutes. This allows the case where the user
    # has no session, and opens multiple tabs using the same remember_me token.
    $self->store->expire($token_key, 5 * 60);
    $self->store->exists($token_key);
}

sub allocate_remember_me_token {
    my ($self, $user_name) = @_;

    if (
        my $normalized_name = $self->sql->select_single_value(
            'SELECT name FROM editor WHERE lower(name) = lower(?)',
            $user_name
        )
    ) {
        my $token = generate_token();

        my $key = "$normalized_name|$token";
        $self->store->set($key, 1);

        # Expire tokens after 1 year.
        $self->store->expire($key, 60 * 60 * 24 * 7 * 52);

        return ($normalized_name, $token);
    }
    else {
        return undef;
    }
}

sub is_email_used_elsewhere {
    my ($self, $email, $user_id) = @_;

    return 1 if $self->sql->select_single_value(
        'SELECT 1 FROM editor WHERE lower(email) = lower(?) AND id != ?', $email, $user_id);
    return 0;
}

sub is_name_used {
    my ($self, $name) = @_;

    return 1 if $self->sql->select_single_value(
        'SELECT 1 FROM editor WHERE lower(name) = lower(?)', $name);
    return 1 if $self->sql->select_single_value(
        'SELECT 1 FROM old_editor_name WHERE lower(name) = lower(?)', $name);
    return 0;
}

sub are_names_equivalent {
    my ($self, $name1, $name2) = @_;

    return $self->sql->select_single_value(
        'SELECT lower(?) = lower(?)', $name1, $name2);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Editor - database level loading support for
Editors

=head1 DESCRIPTION

Provides support for fetching editors from the database

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
