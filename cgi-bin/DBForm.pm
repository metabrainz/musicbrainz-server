#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 1998 Kevin Murphy
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
package DBForm;

use DBI;
use DBDefs;
use strict;
use CGI::Pretty qw/:standard/;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = ''; 

################################################################################
sub DBConnect
{
  my($DSN,$User,$Passwd)=@_;
  my($dbh);
  if (!$DSN){$DSN=DBDefs->DSN;}
  if (!$User){$User=DBDefs->DB_USER;}
  if (!$Passwd){$Passwd=DBDefs->DB_PASSWD;}
  $dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD) ||
    return("Unable to connect to database DBDefs->DSN as DBDefs->DB_USER: DBI->errst",0);
  return(0,$dbh);
}

sub DBDisconnect
{
  my($dbh) = @_;
  $dbh->disconnect;
}
################################################################################
sub DBLoadSingle
{
  my($dbh,$Table,%Query)=@_;
  my($QueryString)="select * from $Table where";
  my($key,$GoneOnce,$sth,@ColNames,@Returned,%Result);
  
  $QueryString = $QueryString . DBHashToSelect($dbh,%Query);

#print STDERR "$QueryString\n";
  $sth = $dbh->prepare($QueryString);
  $sth->execute;
  if ($sth->errstr)
  {
    return($sth->errstr,0)
  }
  elsif(!$sth->rows)
  {
    return("No Rows Returned",0);
  }
  elsif($sth->rows>1)
  {
    return("More Than One Row Returned",0);
  }
  else
  {
    @ColNames= @{$sth->{NAME}};
    
    @Returned = $sth->fetchrow_array;

    for (my $i=0; $i < @Returned; $i++)
    {
      $Result{$ColNames[$i]} = $Returned[$i];
    }
    return(0,%Result);
  }
}
################################################################################
sub DBSaveSingle
{
  my($dbh,$Table,%Object) = @_;
  my(%Query,$QueryString,$sth,$rv);

  $Query{'Id'} = $Object{'Id'};

  if (DBLoadSingle($dbh,$Table,%Query))
  {
    $QueryString = "update $Table set " . DBHashToUpdate($dbh,%Object) . " where Id=$Object{'Id'}";
  }
  else
  {
    $QueryString = "insert into $Table " . DBHashToInsert($dbh,%Object);
  }
#print STDERR "$QueryString\n";
  $sth = $dbh->prepare("$QueryString");
  $rv = $sth->execute;
  if ($sth->errstr)
  {
    return($sth->errstr,undef);
  }
  else
  {
    return(0,%Object);
  }
}
################################################################################
sub DBHashToSelect
{
  my ($dbh,%Query)= @_;
  my ($QueryString,$key)="";
  my $GoneOnce = 0;
  foreach $key (keys(%Query))
  {
    if (!$GoneOnce)
    {
      $GoneOnce=1;
    }
    else
    {
      $QueryString = "$QueryString and ";
    }
    $QueryString = "$QueryString $key=" . $dbh->quote($Query{$key}) . " ";
  }
  return($QueryString);
}
################################################################################
sub DBHashToInsert
{
  my ($dbh,%Query)= @_;
  my ($key,$GoneOnce);
  my $QueryString = "(";
  foreach $key (keys(%Query))
  {
    if (!$GoneOnce)
    {
      $GoneOnce=1;
    }
    else
    {
      $QueryString = "$QueryString,"; 
    }
    $QueryString = "$QueryString $key";
  }
  $QueryString = "$QueryString) values ( ";
 
  foreach $key (keys(%Query))
  {
    if (!$GoneOnce)
    {
      $GoneOnce=1;
    }
    else
    {
      $QueryString = "$QueryString,"; 
    }
    if($Query{$key})
    {
      $QueryString = "$QueryString ". $dbh->quote($Query{$key});
    }
    else
    { 
      $QueryString = "$QueryString NULL";
    }
  }
  return($QueryString);
}
################################################################################
sub DBHashToUpdate
{
  my ($dbh,%Query)= @_;
  my $QueryString = "";
  my ($key,$GoneOnce);
  foreach $key (keys(%Query))
  {
    if (!$GoneOnce)
    {
      $GoneOnce=1;
    }
    else
    {
      $QueryString = "$QueryString,"; 
    }
    if (defined($Query{$key}))
    {
      $QueryString = "$QueryString $key=" . $dbh->quote($Query{$key});
    }
    else
    {
      $QueryString = "$QueryString $key=NULL";
    }
  }
  return($QueryString);
}
################################################################################
sub DBGetTypes
{
  my($dbh,$Table)=@_;
  my($sth,@ColTypes,@ColNames,$ColName,%Types);
  $sth = $dbh->prepare("select * from $Table limit 1");
  $sth->execute;
  @ColTypes=@{$sth->{'TYPE'}};
  @ColNames=@{$sth->{'NAME'}};
  for(my $i=0; $i<@ColNames; $i++)
  {
    $Types{$ColNames[$i]}=$ColTypes[$i];
  }
  return (%Types);
}
################################################################################
sub DBMakeForm
{
  my($dbh,$Table,$Defaults,$FieldMask)=@_;
  my (@FormFields,$FormField,@FormTable,$key,$Row);
  my $Form = start_form();
  my %Types = DBGetTypes($dbh,$Table);
  my %Tables = DBListTables($dbh);
  foreach $key (sort{ $Types{$b} cmp $Types{$a}}( keys %Types))
  {
    if($key eq "Id")
    {
      push(@FormFields,hidden(-name=>'Id',-value=>${$Defaults}{$key}));
    }
    elsif (grep(/$key/,@{$FieldMask}))
    {
SWITCH:
      {
        if ($Types{$key} == &DBD::mysql::FIELD_TYPE_BLOB)
        {
          push(@FormFields,td([$key,textarea(-rows=>8, 
                  -columns=>40,
                  -wrap=>'soft',
                  -name=>$key,
                  -default=>${$Defaults}{$key})]));
          last SWITCH;
        }
        
        if (($Types{$key} == &DBD::mysql::FIELD_TYPE_LONG)&&($Tables{$key}))
        {
          push (@FormFields,td([$key,DBMakeMenu($dbh,$key,${$Defaults}{$key})]));
          last SWITCH;
        }

        if ($Types{$key} == &DBD::mysql::FIELD_TYPE_TINY)
        {
          my $checked;
          if (${$Defaults}{$key}==1)
          {
            push(@FormFields,td({-colspan=>2},checkbox(-name=>$key,
                  -value=>1,
                  -checked=>1,
                  -label=>$key)));
            push(@FormFields,"<input type=\"hidden\" name=\"$key\" value=\"0\">");
          }
          else
          {
            push(@FormFields,td({-colspan=>2},checkbox(-name=>$key,
                  -value=>1,
                  -label=>$key)));
            push(@FormFields,"<input type=\"hidden\" name=\"$key\" value=\"0\">");
          }
          last SWITCH;
        }
        push(@FormFields,td([$key,textfield(-name=>$key, 
                -size=>40,
                -default=>${$Defaults}{$key})]));
      }
    }
  }

  push(@FormFields,td({-colspan=>2,-align=>'center'},submit(-value=>'Submit')));
  foreach $FormField(@FormFields)
  {
    push (@FormTable,$FormField);
  }

  $Form = $Form . table({-border=>1},Tr(\@FormTable));
  
  return ($Form);
}
################################################################################
sub DBMakeMenu
{
  my($dbh,$Table,$Default)=@_;
  my(@Row,@Values,%Labels,$Popup);
  my $sth=$dbh->prepare("select Id,Name from $Table");
  $sth->execute;
  while (@Row=$sth->fetchrow_array())
  {
    push(@Values,$Row[0]);
    $Labels{$Row[0]}=$Row[1];
  }
  $Popup = popup_menu(-name=>$Table,
      -'values'=>\@Values,
      -labels=>\%Labels,
      -default=>$Default);
  return ($Popup);
}
################################################################################
sub DBListTables
{
  my ($dbh)=@_;
  my ($Row,%Tables);
  my $sth=$dbh->prepare("show tables");
  $sth->execute();
  while ($Row=($sth->fetchrow_arrayref()))
  { 
    $Tables{${$Row}[0]} = 1;
  }
  return (%Tables);
}
################################################################################
sub DBGetPostedData
{
  my @ParamNames = param();
  my %ParamData;
  foreach (@ParamNames)
  {
    $ParamData{$_} = param($_);
  }
  return %ParamData;
}
################################################################################
sub DBPutParamData
{
  my(%Object)=@_;
  my($key);
  foreach $key (keys(%Object))
  {
    param(-name=>$key,-value=>$Object{$key});
  }
  return 0;
}
################################################################################

1;
