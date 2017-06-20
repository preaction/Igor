package Igor::Runnable::Timeout::Alarm;
our $VERSION = '0.014';
# ABSTRACT: Use `alarm` to set a timeout for a command

=head1 SYNOPSIS

    ### In a Runnable module
    package My::Runnable::Script;
    use Moo;
    with 'Igor::Runnable', 'Igor::Runnable::Timeout::Alarm';
    has '+timeout' => ( default => 60 ); # Set timeout: 60s
    sub run { }

    ### In a container config file
    runnable:
        $class: My::Runnable::Script
        $with:
            - 'Igor::Runnable::Timeout::Alarm'
        timeout: 60

=head1 DESCRIPTION

This role adds a timeout for a runnable module using Perl's L<alarm()|perlfunc/alarm>
function. When the timeout is reached, a warning will be printed to C<STDERR> and the
program will exit with code C<255>.

=head1 SEE ALSO

L<Igor::Runnable>, L<perlfunc/alarm>, L<Time::HiRes>

=cut

use strict;
use warnings;
use Moo::Role;
use Types::Standard qw( Num CodeRef );
use Time::HiRes qw( alarm );

=attr timeout

The time in seconds this program is allowed to run. This can include
a decimal (like C<6.5> seconds).

=cut

has timeout => (
    is => 'ro',
    isa => Num,
    required => 1,
);

=attr _timeout_cb

A callback to be run when the timeout is reached. Override this to change
what warning is printed to C<STDERR> and what exit code is used (or whether
the process exits at all).

=cut

has _timeout_cb => (
    is => 'ro',
    isa => CodeRef,
    default => sub {
        warn "Timeout reached!\n";
        exit 255;
    },
);

=method run

This role wraps the C<run> method of your runnable class to add the timeout.

=cut

around run => sub {
    my ( $orig, $self, @args ) = @_;
    local $SIG{ALRM} = $self->_timeout_cb;
    alarm $self->timeout;
    return $self->$orig( @args );
};

1;
