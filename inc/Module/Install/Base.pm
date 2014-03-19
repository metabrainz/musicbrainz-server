package Module::Install::Base;

use strict 'vars';
use vars qw{$VERSION};
BEGIN {
        $VERSION = '0.94';
}

# Suspend handler for "redefined" warnings
BEGIN {
        my $w = $SIG{__WARN__};
        $SIG{__WARN__} = sub { $w };
}

=pod

=head1 NAME

Module::Install::Base - Base class for Module::Install extensions

=head1 SYNOPSIS

In a B<Module::Install> extension:

    use Module::Install::Base ();
    @ISA = qw(Module::Install::Base);

=head1 DESCRIPTION

This module provide essential methods for all B<Module::Install>
extensions, in particular the common constructor C<new> and method
dispatcher C<AUTOLOAD>.

=head1 METHODS

=over 4

=item new(%args)

Constructor -- need to preserve at least _top

=cut

sub new {
        my $class = shift;
        unless ( defined &{"${class}::call"} ) {
                *{"${class}::call"} = sub { shift->_top->call(@_) };
        }
        unless ( defined &{"${class}::load"} ) {
                *{"${class}::load"} = sub { shift->_top->load(@_) };
        }
        bless { @_ }, $class;
}

=pod

=item AUTOLOAD

The main dispatcher - copy extensions if missing

=cut

sub AUTOLOAD {
        local $@;
        my $func = eval { shift->_top->autoload } or return;
        goto &$func;
}

=pod

=item _top()

Returns the top-level B<Module::Install> object.

=cut

sub _top {
        $_[0]->{_top};
}

=pod

=item admin()

Returns the C<_top> object's associated B<Module::Install::Admin> object
on the first run (i.e. when there was no F<inc/> when the program
started); on subsequent (user-side) runs, returns a fake admin object
with an empty C<AUTOLOAD> method that does nothing at all.

=cut

sub admin {
        $_[0]->_top->{admin}
        or
        Module::Install::Base::FakeAdmin->new;
}

=pod

=item is_admin()

Tells whether this is the first run of the installer (on
author's side). That is when there was no F<inc/> at
program start. True if that's the case. False, otherwise.

=cut

sub is_admin {
        $_[0]->admin->VERSION;
}

sub DESTROY {}

package Module::Install::Base::FakeAdmin;

my $fake;

sub new {
        $fake ||= bless(\@_, $_[0]);
}

sub AUTOLOAD {}

sub DESTROY {}

# Restore warning handler
BEGIN {
        $SIG{__WARN__} = $SIG{__WARN__}->();
}

1;

=pod

=back

=head1 SEE ALSO

L<Module::Install>

=head1 AUTHORS

Audrey Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2003, 2004 by Audrey Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
