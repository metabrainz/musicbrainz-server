#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________
                                                                               
package UserStuff;
use TableBase;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use MusicBrainz;

use constant AUTOMOD_FLAG => 1;
use constant BOT_FLAG => 2;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

sub Login
{
   my ($this, $user, $pwd) = @_;
   my ($ok, $sth, $dbuser, $sql);
   my @row;

   $ok = 0;

   return (0) if ($user =~ m/Anonymous/i);
   return (0) if ($user =~ m/ModBot/i);
   return (0) if ($user =~ m/FreeDB/i);

   $sql = Sql->new($this->{DBH});
   $dbuser = $sql->Quote($user);
   if ($sql->Select(qq/select name,password,privs,id 
                   from Moderator where name ilike $dbuser/))
   {
       @row = $sql->NextRow();
       if ($pwd eq $row[1])
       {
          $ok = 1;
       }
       $sql->Finish;   
   }

   return ($ok, $row[0], $row[2], $row[3]);
}

sub CreateLogin
{
   my ($this, $user, $pwd, $pwd2) = @_;
   my ($sql, $uid, $dbuser);

   $sql = Sql->new($this->{DBH});
   if ($pwd ne $pwd2)
   {
       return "The given passwords do not match. Please try again.";
   }
   if ($pwd eq "")
   {
       return "You cannot leave the password blank. Please try again.";
   }
   if ($user eq "")
   {
       return "You cannot leave the user name blank. Please try again."
   }

   $dbuser = $sql->Quote($user);
   $pwd = $sql->Quote($pwd);

   my $msg = eval
   {
       $sql->Begin;

       if ($sql->Select("select id from Moderator where name ilike $dbuser"))
       {
           $sql->Finish;
           $sql->Rollback;
           return ("That login already exists. Please choose another login name.");
       }

       $sql->Do(qq/
                insert into Moderator (Name, Password, Privs, ModsAccepted, 
                ModsRejected, MemberSince) values ($dbuser, $pwd, 0, 0, 0, now())
                /);

       $uid = $sql->GetLastInsertId("Moderator");
       $sql->Commit;

       return "";
   };
   if ($@)
   {
       $sql->Rollback;
       return ("A database error occurred. ($@)", undef, undef, undef);
   }
   if ($msg ne '')
   {
       return $msg; 
   }

   return ("", $user, 0, $uid);
} 

sub GetUserPasswordAndId
{
   my ($this, $username) = @_;
   my ($sql, $dbuser);

   $sql = Sql->new($this->{DBH});
   return undef if (!defined $username || $username eq '');

   $dbuser = $sql->Quote($username);
   if ($sql->Select(qq|select password, id from Moderator 
                       where name ilike $dbuser|))
   {
       my @row = $sql->NextRow();
       $sql->Finish;
       return ($row[0], $row[1]);
   }

   return (undef, undef);
} 

sub GetUserInfo
{
   my ($this, $uid) = @_;
   my ($sql, $dbuser);

   $sql = Sql->new($this->{DBH});
   return undef if (!defined $uid || $uid == 0);

   if ($sql->Select(qq|select name, email, password, privs, modsaccepted, 
                              modsrejected, WebUrl, MemberSince, Bio 
                         from Moderator 
                        where id = $uid|))
   {
       my @row = $sql->NextRow();
       $sql->Finish;
       return { name=>$row[0],
                email=>$row[1],
                passwd=>$row[2],
                privs=>$row[3],
                modsaccepted=>$row[4],
                modsrejected=>$row[5],
                weburl =>$row[6],
                membersince =>$row[7],
                bio=>$row[8] };
   }
   return undef;
} 

sub SetUserInfo
{
   my ($this, $uid, $email, $password, $weburl, $bio) = @_;
   my ($sql, $query);

   $sql = Sql->new($this->{DBH});
   return undef if (!defined $uid || $uid == 0);

   $query = "update Moderator set";

   $query .= " email = " . $sql->Quote($email) . ","
       if (defined $email && $email ne '');

   $query .= " password = " . $sql->Quote($password) . ","
       if (defined $password && $password ne '');

   $query .= " weburl = " . $sql->Quote($weburl) . ","
       if (defined $weburl && $weburl ne '');

   $query .= " bio = " . $sql->Quote($bio) . ","
       if (defined $bio && $bio ne '');

   if ($query =~ m/,$/)
   {
      chop($query);
   }
   else
   {
      # No valid args were specified, so bail
      return;
   }

   $query .= " where id = $uid";

   # No transaction here, since its a simple one-row update
   $sql->Do($query);

   return 1;
} 

sub GetUserType
{
   my ($this, $privs) = @_;
   my $type = "";

   $type = "Automatic Moderator "
      if ($this->IsAutoMod($privs));

   $type = "Internal/Bot User "
      if ($this->IsBot($privs));

   $type = "Normal User"
      if ($type eq "");

   return $type;
}

sub IsAutoMod
{
   my ($this, $privs) = @_;

   return ($privs & AUTOMOD_FLAG) > 0;
}

sub IsBot
{
   my ($this, $privs) = @_;

   return ($privs & BOT_FLAG) > 0;
}
