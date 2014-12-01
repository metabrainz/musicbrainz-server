#line 1
package Module::Install::AuthorTests;

use 5.005;
use strict;
use Module::Install::Base;
use Carp ();

#line 16

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
  $VERSION = '0.002';
  $ISCORE  = 1;
  @ISA     = qw{Module::Install::Base};
}

#line 42

sub author_tests {
  my ($self, @dirs) = @_;
  _add_author_tests($self, \@dirs, 0);
}

#line 56

sub recursive_author_tests {
  my ($self, @dirs) = @_;
  _add_author_tests($self, \@dirs, 1);
}

sub _wanted {
  my $href = shift;
  sub { /\.t$/ and -f $_ and $href->{$File::Find::dir} = 1 }
}

sub _add_author_tests {
  my ($self, $dirs, $recurse) = @_;
  return unless $Module::Install::AUTHOR;

  my @tests = $self->tests ? (split / /, $self->tests) : 't/*.t';

  # XXX: pick a default, later -- rjbs, 2008-02-24
  my @dirs = @$dirs ? @$dirs : Carp::confess "no dirs given to author_tests";
     @dirs = grep { -d } @dirs;

  if ($recurse) {
    require File::Find;
    my %test_dir;
    File::Find::find(_wanted(\%test_dir), @dirs);
    $self->tests( join ' ', @tests, map { "$_/*.t" } sort keys %test_dir );
  } else {
    $self->tests( join ' ', @tests, map { "$_/*.t" } sort @dirs );
  }
}

#line 107

1;
