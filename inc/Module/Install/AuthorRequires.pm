use strict;
use warnings;

package Module::Install::AuthorRequires;

use base 'Module::Install::Base';

# cargo cult
BEGIN {
    our $VERSION = '0.02';
    our $ISCORE  = 1;
}

sub author_requires {
    my $self = shift;

    return $self->{values}->{author_requires}
        unless @_;

    my @added;
    while (@_) {
        my $mod = shift or last;
        my $version = shift || 0;
        push @added, [$mod => $version];
    }

    push @{ $self->{values}->{author_requires} }, @added;
    $self->admin->author_requires(@added);

    return map { @$_ } @added;
}

1;

__END__

=head1 NAME

Module::Install::AuthorRequires - declare author-only dependencies

=head1 SYNOPSIS

    author_requires 'Some::Module';
    author_requires 'Another::Module' => '0.42';

=head1 DESCRIPTION

Modules often have optional requirements, for example dependencies that are
useful for (optional) tests, but not required for the module to work properly.

Usually you want all developers of a project to have these optional modules
installed. However, simply telling everyone or printing diagnostic messages if
optional dependencies are missing often isn't enough to make sure all authors
have all optional modules installed.

C<Module::Install> already has a way of detecting an author environment, so an
easy way to achieve the above would be something like:

    if ($Module::Install::AUTHOR) {
        requires 'Some::Module';
        requires 'Another::Module' => '0.42';
    }

Unfortunately, that'll also make the optional dependencies show up in the
distributions C<META.yml> file, which is obviously wrong, as they aren't
actually hard requirements.

Working that around requires a considerable amount of non-trivial Makefile.PL
hackery, or simply using this module's C<author_requires> command.

=head1 COMMANDS

=head2 author_requires

    author_requires $module;
    author_requires $module => $version;

This declares a hard dependency, that's only enforced in author environments
and is not put in the generate C<META.yml> file of the distribution.

=head1 AUTHOR

Florian Ragwitz E<lt>rafl@debian.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009  Florian Ragwitz

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
