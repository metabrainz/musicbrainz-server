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
use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use MusicBrainz;

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub Login
{
   my ($this, $user, $pwd, $sess) = @_;
   my ($ok, $sth);

   $ok = 0;

   $user = $this->{DBH}->quote($user);
   $sth = $this->{DBH}->prepare(qq/
          select name,password,privs,id from ModeratorInfo where name = $user/);
   if ($sth->execute && $sth->rows)
   {
       my @row;
   
       @row = $sth->fetchrow_array;
       if ($pwd eq $row[1])
       {
          $ok = 1;
          $sess->{user} = $user;
          $sess->{privs} = $row[2];
          $sess->{uid} = $row[3];
       }
   }
   $sth->finish;   

   return $ok;
}

sub CreateLogin
{
   my ($this, $user, $pwd, $pwd2, $sess) = @_;
   my ($sth);

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

   $user = $this->{DBH}->quote($user);
   $pwd = $this->{DBH}->quote($pwd);
   $sth = $this->{DBH}->prepare(qq/
                         select id from ModeratorInfo where name = $user
                         /);
   if ($sth->execute && $sth->rows)
   {
       $sth->finish;
       return "That login already exists. Please choose another login name."
   }
   $sth->finish;

   $this->{DBH}->do(qq/
            insert into ModeratorInfo (Name, Password, Privs, ModsAccepted, 
            ModsRejected) values ($user, $pwd, 0, 0, 0)
            /);

   $sess->{user} = $user;
   $sess->{privs} = 0;
   $sess->{uid} = $this->GetLastInsertId();
   $sth->finish;

   return "";
} 
