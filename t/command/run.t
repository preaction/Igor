
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

my $SHARE_DIR = path( $FindBin::Bin, '..', 'share' );
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

done_testing;
