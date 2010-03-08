package Module::Install::AuthorTests;

use 5.005;
use strict;
use Module::Install::Base;
use Carp ();

=head1 NAME

Module::Install::AuthorTests - designate tests only run by module authors

=head1 VERSION

0.002

=cut

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
  $VERSION = '0.002';
  $ISCORE  = 1;
  @ISA     = qw{Module::Install::Base};
}

=head1 COMMANDS

This plugin adds the following Module::Install commands:

=head2 author_tests

  author_tests('xt');

This declares that the test files found in the directory F<./xt> should be run
only if the module is being built by an author.  For an explanation, see below.

You may declare multiple test directories by passing a list of tests.  Since
tests are not recursive by default, it should be safe to use a subdirectory of
F<./t> for author tests, like:

  author_tests('t/author');

=cut

sub author_tests {
  my ($self, @dirs) = @_;
  _add_author_tests($self, \@dirs, 0);
}

=head2 recursive_author_tests

  recursive_author_tests('xt');

This acts like C<author_tests>, but will look for tests in directories below
F<./xt> as well as in the directory itself.

=cut

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

=head1 HOW IT WORKS

"Is this being run by an author?" is determined internally by Module::Install,
but at the time of the writing of this version it's determined by the existence
of a directory called F<.author> in F<./inc>.  (On VMS, it's F<_author>.)  This
directory is created when Module::Install's F<Makefile.PL> is run in a
directory where no F<./inc> directory exists.

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>. I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2008, Ricardo SIGNES.  This program is free software;  you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
