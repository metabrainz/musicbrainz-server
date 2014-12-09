#line 1
package Module::Install::Catalyst;

use strict;

use base qw/ Module::Install::Base /;
our @ISA;
require Module::Install::Base;

use File::Find;
use FindBin;
use File::Copy::Recursive;
use File::Spec ();
use Getopt::Long ();
use Data::Dumper;

my $SAFETY = 0;

our @IGNORE =
  qw/Build Build.PL Changes MANIFEST META.yml Makefile.PL Makefile README
  _build blib lib script t inc .*\.svn \.git _darcs \.bzr \.hg
  debian build-stamp install-stamp configure-stamp/;

#line 52

sub catalyst {
    my $self = shift;

    if($Module::Install::AUTHOR) {
        $self->include("File::Copy::Recursive");
    }

    print <<EOF;
*** Module::Install::Catalyst
EOF
    $self->catalyst_files;
    print <<EOF;
*** Module::Install::Catalyst finished.
EOF
}

#line 76

sub catalyst_files {
    my $self = shift;

    chdir $FindBin::Bin;

    my @files;
    opendir CATDIR, '.';
  CATFILES: for my $name ( readdir CATDIR ) {
        for my $ignore (@IGNORE) {
            next CATFILES if $name =~ /^$ignore$/;
            next CATFILES if $name !~ /\w/;
        }
        push @files, $name;
    }
    closedir CATDIR;
    my @path = split '-', $self->name;
    for my $orig (@files) {
        my $path = File::Spec->catdir( 'blib', 'lib', @path, $orig );
        File::Copy::Recursive::rcopy( $orig, $path );
    }
}

#line 104

sub catalyst_ignore_all {
    my ( $self, $ignore ) = @_;
    @IGNORE = @$ignore;
}

#line 115

sub catalyst_ignore {
    my ( $self, @ignore ) = @_;
    push @IGNORE, @ignore;
}

#line 131

1;
