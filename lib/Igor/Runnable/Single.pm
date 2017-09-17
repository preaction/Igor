package Igor::Runnable::Single;
our $VERSION = '0.015';
# ABSTRACT: Only allow one instance of this command at a time

=head1 SYNOPSIS

    ### In a Runnable module
    package My::Runnable::Script;
    use Moo;
    with 'Igor::Runnable', 'Igor::Runnable::Single';
    has '+pid_file' => ( default => '/var/run/runnable-script.pid' );
    sub run { }

    ### In a container config file
    runnable:
        $class: My::Runnable::Script
        $with:
            - 'Igor::Runnable::Single'
        pid_file: /var/run/runnable-script.pid

=head1 DESCRIPTION

This role checks to ensure that only one instance of the command is
running at a time. If another instance tries to run, it dies with an
error instead.

Users should have access to read/write the path pointed to by
L</pid_file>, and to read/write the directory containing the PID file.

If the command exits prematurely, the PID file will not be cleaned up.
If this is undesirable, make sure to trap exceptions in your C<run()>
method and return the exit code you want.

=head1 SEE ALSO

L<Igor::Runnable>

=cut

use strict;
use warnings;
use Moo::Role;
use Types::Path::Tiny qw( Path );

=attr pid_file

The path to a file containing the PID of the currently-running script.

=cut

has pid_file => (
    is => 'ro',
    isa => Path,
    required => 1,
    coerce => 1,
);

=method run

This role wraps the C<run> method of your runnable class to check that
there is no running instance of this task (the PID file does not exist).

=cut

before run => sub {
    my ( $self, @args ) = @_;
    if ( $self->pid_file->exists ) {
        my $pid = $self->pid_file->slurp;
        die "Process already running (PID: $pid)\n";
    }
    $self->pid_file->spew( $$ );
};

after run => sub {
    my ( $self ) = @_;
    unlink $self->pid_file;
};

1;
