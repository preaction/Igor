
=head1 DESCRIPTION

This file tests the L<Igor::Runner::Command::run> class to ensure it
loads the L<Igor> container, finds the right service, and executes
the service's C<run()> method with the right arguments and returning
the exit code.

This file uses the C<t/lib/Local/Runnable.pm> file as a runnable object,
and C<t/share/container.yml> as the L<Igor> container.

=head1 SEE ALSO

L<Igor::Runner::Command::run>

=cut

use strict;
use warnings;
use Test::More;
use Test::Lib;
use Local::Runnable;
use FindBin ();
use Path::Tiny qw( path );
use Igor::Runner::Command::run;

local $ENV{IGOR_PATH} = undef;
my $SHARE_DIR = path( $FindBin::Bin, '..', 'share', 'runner' );
my $class = 'Igor::Runner::Command::run';

subtest 'run a service' => sub {
    my $container = $SHARE_DIR->child( 'container.yml' );
    my $exit = $class->run( $container => success => qw( 1 2 3 ) );
    is $exit, 0, 'exit code is correct';
    is_deeply $Local::Runnable::got_args, [qw( 1 2 3 )], 'args are correct';
};

subtest 'find container in IGOR_PATH' => sub {
    local $ENV{IGOR_PATH} = "$SHARE_DIR";
    my $exit = $class->run( container => success => qw( 1 ) );
    is $exit, 0, 'exit code is correct';
    is_deeply $Local::Runnable::got_args, [qw( 1 )], 'args are correct';
};

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

subtest 'service dependency not found' => sub {
    local $ENV{IGOR_PATH} = "$SHARE_DIR";
    my $c = $SHARE_DIR->child( 'container.yml' );
    eval { $class->run( container => dep_missing => qw( 1 ) ); };
    ok $@, 'exception thrown';
    like $@, qr{\QCould not load service "dep_missing" in container "$c": Service 'NOT_FOUND' not found},
        'error message is correct';
};

done_testing;
