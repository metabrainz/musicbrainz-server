package Module::Install::Can;

use strict;
use Config                ();
use File::Spec            ();
use ExtUtils::MakeMaker   ();
use Module::Install::Base ();

use vars qw{$VERSION @ISA $ISCORE};
BEGIN {
        $VERSION = '0.94';
        @ISA     = 'Module::Install::Base';
        $ISCORE  = 1;
}

# check if we can load some module
### Upgrade this to not have to load the module if possible
sub can_use {
        my ($self, $mod, $ver) = @_;
        $mod =~ s{::|\\}{/}g;
        $mod .= '.pm' unless $mod =~ /\.pm$/i;

        my $pkg = $mod;
        $pkg =~ s{/}{::}g;
        $pkg =~ s{\.pm$}{}i;

        local $@;
        eval { require $mod; $pkg->VERSION($ver || 0); 1 };
}

# check if we can run some command
sub can_run {
        my ($self, $cmd) = @_;

        my $_cmd = $cmd;
        return $_cmd if (-x $_cmd or $_cmd = MM->maybe_command($_cmd));

        for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
                next if $dir eq '';
                my $abs = File::Spec->catfile($dir, $_[1]);
                return $abs if (-x $abs or $abs = MM->maybe_command($abs));
        }

        return;
}

# can we locate a (the) C compiler
sub can_cc {
        my $self   = shift;
        my @chunks = split(/ /, $Config::Config{cc}) or return;

        # $Config{cc} may contain args; try to find out the program part
        while (@chunks) {
                return $self->can_run("@chunks") || (pop(@chunks), next);
        }

        return;
}

# Fix Cygwin bug on maybe_command();
if ( $^O eq 'cygwin' ) {
        require ExtUtils::MM_Cygwin;
        require ExtUtils::MM_Win32;
        if ( ! defined(&ExtUtils::MM_Cygwin::maybe_command) ) {
                *ExtUtils::MM_Cygwin::maybe_command = sub {
                        my ($self, $file) = @_;
                        if ($file =~ m{^/cygdrive/}i and ExtUtils::MM_Win32->can('maybe_command')) {
                                ExtUtils::MM_Win32->maybe_command($file);
                        } else {
                                ExtUtils::MM_Unix->maybe_command($file);
                        }
                }
        }
}

1;

__END__

=pod

=head1 NAME

Module::Install::Can - Utility functions for capability detection

=head1 DESCRIPTION

C<Module::Install::Can> contains a number of functions for authors to use
when creating customised smarter installers. The functions simplify
standard tests so that you can express your dependencies and conditions
much more simply, and make your installer much easier to maintain.

=head1 COMMANDS

=head2 can_use

  can_use('Module::Name');
  can_use('Module::Name', 1.23);

The C<can_use> function tests the ability to load a specific named
module. Currently it will also actually load the module in the
process, although this may change in the future.

Takes an optional second param of a version number. The currently
installed version of the module will be tested to make sure it is
equal to or greater than the specified version.

Returns true if the module can be loaded, or false (in both scalar or
list context) if not.

=head2 can_run

  can_run('cvs');

The C<can_run> function tests the ability to run a named command or
program on the local system.

Returns true if so, or false (both in scalar and list context) if not.

=head2 can_cc

  can_cc();

The C<can_cc> function test the ability to locate a C compiler on the
local system. Returns true if the C compiler can be found, or false
(both in scalar and list context) if not.

=head1 TO DO

Currently, the use of a C<can_foo> command in a single problem domain
(for example C<can_use>) results in the inclusion of additional
functionality from different problem domains (for example C<can_run>).

This module should ultimately be broken up, and the individual
functions redestributed to different domain-specific extensions.

=head1 AUTHORS

Audrey Tang E<lt>autrijus@autrijus.orgE<gt>

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 SEE ALSO

L<Module::Install>, L<Class::Inspector>

=head1 COPYRIGHT

Copyright 2006 Audrey Tang, Adam Kennedy.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
