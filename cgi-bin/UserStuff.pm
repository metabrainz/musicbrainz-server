#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use MusicBrainz;

sub Login
{
   my ($user, $pwd, $sess) = @_;
   my ($mb, $ok, $sth);

   $mb = MusicBrainz::new();
   $mb->Login();
   $ok = 0;

   $user = $mb->{DBH}->quote($user);
   $sth = $mb->{DBH}->prepare(qq/
          select name,password,privs from ModeratorInfo where name = $user/);
   if ($sth->execute && $sth->rows)
   {
       my @row;
   
       @row = $sth->fetchrow_array;
       if ($pwd eq $row[1])
       {
          $ok = 1;
          $sess->{user} = $user;
          $sess->{privs} = $row[2];
       }
   }
   $sth->finish;   
   $mb->Logout();

   return $ok;
}

sub CreateLogin
{
   my ($user, $pwd, $pwd2, $sess) = @_;
   my ($mb, $sth);

   $mb = MusicBrainz::new();

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

   $mb->Login();
   $user = $mb->{DBH}->quote($user);
   $pwd = $mb->{DBH}->quote($pwd);
   $sth = $mb->{DBH}->prepare(qq/
                         select name from ModeratorInfo where name = $user
                         /);
   if ($sth->execute && $sth->rows)
   {
       $sth->finish;
       $mb->Logout();
       return "That login already exists. Please choose another login name."
   }
   $sth->finish;

   $mb->{DBH}->do(qq/
            insert into ModeratorInfo (Name, Password, Privs) 
            values ($user, $pwd, 0)
            /);

   $sess->{user} = $user;
   $sth->finish;
   $mb->Logout();

   return "";
} 
