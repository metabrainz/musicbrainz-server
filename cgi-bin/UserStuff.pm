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

   $sql = Sql->new($this->{DBH});
   $dbuser = $sql->Quote($user);
   if ($sql->Select(qq/select name,password,privs,id 
                   from ModeratorInfo where name = $dbuser/))
   {
       @row = $sql->NextRow();
       if ($pwd eq $row[1])
       {
          $ok = 1;
       }
       $sql->Finish;   
   }

   return ($ok, $user, $row[2], $row[3]);
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
   if ($sql->Select("select id from ModeratorInfo where name = $dbuser"))
   {
       $sql->Finish;
       return "That login already exists. Please choose another login name."
   }

   $sql->Do(qq/
            insert into ModeratorInfo (Name, Password, Privs, ModsAccepted, 
            ModsRejected) values ($dbuser, $pwd, 0, 0, 0)
            /);

   $uid = $sql->GetLastInsertId();

   return ("", $user, 0, $uid);
} 

sub GetUserPasswordAndId
{
   my ($this, $username) = @_;
   my ($sql, $dbuser);

   $sql = Sql->new($this->{DBH});
   return undef if (!defined $username || $username eq '');

   $dbuser = $sql->Quote($username);
   if ($sql->Select(qq|select password, id from ModeratorInfo 
                       where name = $dbuser|))
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
                         from ModeratorInfo 
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
