package MusicBrainz::Server::Authentication::Store;

use strict;
use warnings;

use MusicBrainz::Server::Editor;
use UserPreference;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    return $c->model('User')->load({ username => $authinfo->{username} });
}

sub for_session
{
    my ($self, $c, $user) = @_;

    return {
        'id' => $user->id,
        'privs' => $user->privs,
        'name' => $user->name,
        'edits_accepted' => $user->mods_accepted,
        'has_confirmed_email' => $user->email ? 1 : 0,
        'prefs' => $user->preferences->{prefs},
    };
}

sub from_session
{
    my ($self, $c, $frozen_user) = @_;
    my $user = MusicBrainz::Server::Editor->new($c->mb->dbh);
    $user->id($frozen_user->{id});
    $user->name($frozen_user->{name});
    $user->privs($frozen_user->{privs});
    $user->mods_accepted($frozen_user->{edits_accepted});
    $user->{has_confirmed_email} = $frozen_user->{has_confirmed_email};
    
    my $prefs = UserPreference->new;
    $prefs->{prefs} = $frozen_user->{prefs} || {};
    $user->preferences($prefs);

    return $user;
}

1;
