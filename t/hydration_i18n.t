use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;
use FindBin qw( $Bin );
use List::AllUtils qw( any );
use String::ShellQuote qw( shell_quote );
use Test::More;

=head2 Test description

This test checks that any components using hydration exist under
root/static/scripts/.  It also checks that any imported files that use
i18n functions also exist under root/static/scripts/.

This requirement exists because strings bundled for the browser are
only extracted from this subdirectory, avoiding the need to bundle
server-side strings that are never used on the client.

Hydration errors can occur if this requirement is not upheld: while
the component will render in the correct language on the server, once
hydrated it would revert back to English.

=cut

my %checked_files;
my $checkout_dir = Cwd::realpath(File::Spec->catfile($Bin, '../'));
my $scripts_dir = File::Spec->catfile($checkout_dir, 'root/static/scripts/');
my $quoted_checkout_dir = shell_quote($checkout_dir);

my @hydrated_files = split "\n",
    qx{ git -C $quoted_checkout_dir grep -P -l '(?<!function)\\Whydrate[<(]' -- root };

for my $hydrated_file (@hydrated_files) {
    ok(
        $hydrated_file =~ m{^root/static/scripts/},
        "hydrated component file $hydrated_file is under root/static/scripts/",
    );
    $hydrated_file = File::Spec->catfile($checkout_dir, $hydrated_file);
    check_imports($hydrated_file);
}

sub check_imports {
    my @source_path = @_;
    my $source_file = $source_path[scalar(@source_path) - 1];

    return if exists $checked_files{$source_file};
    $checked_files{$source_file} = 1;

    my $quoted_source_file = shell_quote($source_file);
    my $imports = qx { cat $quoted_source_file | tr '\\n' ' ' | grep -P -o "import [^;]+;" | sed -n "s/.*'\\([^']\\+\\)';/\\1/p" };
    my @imports = split "\n", $imports;

    for my $import (@imports) {
        next unless $import =~ /^\./; # ignore node_modules
        next if $import =~ /\.(gif|png|svg)$/;

        $import = Cwd::realpath(
            File::Spec->catfile(
                File::Basename::dirname($source_file),
                $import,
            ),
        );
        next unless $import;

        if ($import !~ /\.[cm]?js$/) {
            $import .= '.js';
        }

        my $import_from_scripts_dir =
            File::Spec->abs2rel($import, $scripts_dir);

        # skip files that are under root/static/scripts/
        next unless $import_from_scripts_dir =~ m{^\.\./};

        # otherwise, check that i18n functions aren't used
        my $quoted_import = shell_quote($import);
        my $l_references = qx{ git grep -P '\\Wl[np_]\\W' -- $quoted_import };
        unless (
            ok(
                !$l_references,
                "No uses of i18n functions in $import",
            )
        ) {
            diag(
                'Import path: ' .
                join(
                    ' -> ',
                    map {
                        File::Spec->abs2rel($_, $checkout_dir)
                    } @source_path,
                ),
            );
        }

        unless (any { $_ eq $import } @source_path) {
            check_imports(@source_path, $import);
        }
    }
}

done_testing;
