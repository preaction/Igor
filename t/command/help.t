
=head1 DESCRIPTION

This file tests the L<Igor::Runner::Command::help> class to ensure it
shows the documentation for the correct class.

This file uses the C<t/lib/Local/Runnable.pm> file as a runnable object,
and C<t/share/container.yml> as the L<Igor> container.

=head1 SEE ALSO

L<Igor::Runner::Command::help>

=cut

use strict;
use warnings;
use Test::More;
use Test::Lib;
use FindBin ();
use Capture::Tiny qw( capture );
use Path::Tiny qw( path );
use Igor::Runner::Command::help;
use Mock::MonkeyPatch;

my $SHARE_DIR = path( $FindBin::Bin, '..', 'share' );
my $class = 'Igor::Runner::Command::help';

subtest 'show class documentation' => sub {
    my $mock = Mock::MonkeyPatch->patch(
        'Igor::Runner::Command::help::pod2usage',
        sub { },
    );
    my $container = $SHARE_DIR->child( 'container.yml' );
    my ( $stdout, $stderr, $exit ) = capture {
        $class->run( $container => 'success' );
    };
    diag $stdout;
    ok !$stderr, 'nothing on stderr' or diag $stderr;
    ok $mock->called, 'mock pod2usage called';
    is_deeply { @{$mock->arguments} },
        {
            -input => path( $FindBin::Bin, '..', 'lib', 'Local', 'Runnable.pm' ),
            -verbose => 2,
            -exitval => 0,
        },
        'arguments to pod2usage are correct'
            or diag explain { @{ $mock->arguments } };
};

subtest 'errors' => sub {

    subtest 'container not found' => sub {
        eval { $class->run( container => success => qw( 1 ) ); };
        ok $@, 'exception thrown';
        is $@, qq{Could not find container "container" in directories: .\n},
            'error message is correct';
    };

    subtest 'service not found' => sub {
        local $ENV{IGOR_PATH} = "$SHARE_DIR";
        my $c = $SHARE_DIR->child( 'container.yml' );
        eval { $class->run( container => NOT_FOUND => qw( 1 ) ); };
        ok $@, 'exception thrown';
        is $@, qq{Could not find service "NOT_FOUND" in container "$c"\n},
            'error message is correct';
    };
};

done_testing;

