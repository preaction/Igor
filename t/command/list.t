
=head1 DESCRIPTION

This file tests the L<Igor::Runner::Command::list> class to ensure it
lists all the container files in C<IGOR_PATH>, and lists all the runnable
services in a particular container.

This file uses the C<t/lib/Local/Runnable.pm> file as a runnable object,
and C<t/share/runner/container.yml> as the L<Igor> container.

=head1 SEE ALSO

L<Igor::Runner::Command::list>

=cut

use strict;
use warnings;
use Term::ANSIColor qw( color );
use Test::More;
use Test::Lib;
use Test::Fatal;
use Local::Runnable;
use FindBin ();
use Path::Tiny qw( path );
use Capture::Tiny qw( capture );
use Igor::Runner::Command::list;

local $ENV{IGOR_PATH} = undef;
my $SHARE_DIR = path( $FindBin::Bin, '..', 'share', 'runner' );
my %COLOR = ( bold => color('bold'), reset => color( 'reset' ) );
my $class = 'Igor::Runner::Command::list';

subtest 'list all containers and services' => sub {
    my $expect_out = join "\n",
        "$COLOR{bold}container$COLOR{reset} -- A container for test purposes",
        "- $COLOR{bold}alias      $COLOR{reset} -- A task that succeeds",
        "- $COLOR{bold}dep_missing$COLOR{reset} -- Local::Runnable - A test runnable module",
        "- $COLOR{bold}extends    $COLOR{reset} -- A task that succeeds",
        "- $COLOR{bold}fail       $COLOR{reset} -- A task that fails",
        "- $COLOR{bold}success    $COLOR{reset} -- A task that succeeds",
        "",
        "$COLOR{bold}undocumented$COLOR{reset}", # This container has no $summary
        "- $COLOR{bold}bar$COLOR{reset} -- Local::Underdocumented",
        "- $COLOR{bold}foo$COLOR{reset} -- Local::Undocumented",
        "";

    local $ENV{IGOR_PATH} = "$SHARE_DIR";
    my ( $stdout, $stderr, $exit ) = capture {
        $class->run;
    };
    ok !$stderr, 'nothing on stderr';
    is $exit, 0, 'exit 0';
    is $stdout, $expect_out, 'containers listed on stdout';
};

subtest 'list one container' => sub {
    my $expect_out = join "\n",
        "$COLOR{bold}container$COLOR{reset} -- A container for test purposes",
        "- $COLOR{bold}alias      $COLOR{reset} -- A task that succeeds",
        "- $COLOR{bold}dep_missing$COLOR{reset} -- Local::Runnable - A test runnable module",
        "- $COLOR{bold}extends    $COLOR{reset} -- A task that succeeds",
        "- $COLOR{bold}fail       $COLOR{reset} -- A task that fails",
        "- $COLOR{bold}success    $COLOR{reset} -- A task that succeeds",
        "";

    local $ENV{IGOR_PATH} = "$SHARE_DIR";
    my ( $stdout, $stderr, $exit ) = capture {
        $class->run( 'container' );
    };
    ok !$stderr, 'nothing on stderr';
    is $exit, 0, 'exit 0';
    is $stdout, $expect_out, 'runnable services listed on stdout';

    subtest 'container with full path' => sub {
        my ( $stdout, $stderr, $exit ) = capture {
            $class->run( $SHARE_DIR->child( 'container.yml' )."" );
        };
        ok !$stderr, 'nothing on stderr';
        is $exit, 0, 'exit 0';
        is $stdout, $expect_out, 'runnable services listed on stdout';
    };

    subtest 'container has no runnable services' => sub {
        my ( $stdout, $stderr, $exit ) = capture {
            $class->run( 'empty' );
        };
        ok !$stdout, 'nothing on stdout';
        ok $exit, 'exit non-zero';
        like $stderr, qr{No runnable services in container "empty"\n},
            "stderr has error message";
    };
};

subtest 'errors' => sub {
    subtest '$IGOR_PATH is not set' => sub {
        local $ENV{IGOR_PATH} = undef;
        is exception { $class->run }, "Cannot list containers: IGOR_PATH environment variable not set\n";
    };
};

done_testing;
