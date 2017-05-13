package Igor::Runnable;
our $VERSION = '0.011';
# ABSTRACT: Role for runnable objects

=head1 SYNOPSIS

    package My::Runnable;
    use Moo;
    with 'Igor::Runnable';
    sub run { ... }

=head1 DESCRIPTION

This role declares your object as runnable by the C<igor run> command.
Runnable objects will be listed by the C<igor list> command, and their
documentation displayed by the C<igor help> command.

=head2 The C<run> method

The C<run> method is the main function of your object. See below for its
arguments and return value.

The C<run> method should be as small as possible, ideally only parsing
command-line arguments and delegating to other objects to do the real
work. Though your runnable object can be used in other code, the API of
the C<run> method is a terrible way to do that, and it is better to keep
your business logic and other important code in another class.

=head2 Documentation

The C<igor help> command will display the documentation of your module:
the C<NAME> (abstract), C<SYNOPSIS>, C<DESCRIPTION>, C<ARGUMENTS>,
C<OPTIONS>, and C<SEE ALSO> sections. This is the same as what
L<Pod::Usage> produces by default.

The C<igor list> command, when listing runnable objects, will display
either the C<summary> attribute or the C<NAME> POD section (abstract)
next to the service name.

=head1 SEE ALSO

L<igor>, L<Igor::Runner>

=cut

use strict;
use warnings;
use Moo::Role;
with 'Igor::Service';
use Types::Standard qw( Str );

=attr summary

A summary of the task to be run. This will be displayed by the C<igor
list> command in the list.

=cut

has summary => (
    is => 'ro',
    isa => Str,
);

=method run

    my $exit_code = $obj->run( @argv );

Execute the runnable object with the given arguments and returning the
exit status. C<@argv> is passed-in from the command line and may contain
options (which you can parse using L<Getopt::Long's GetOptionsFromArray
function|Getopt::Long/Parsing options from an arbitrary array>.

=cut

requires 'run';

1;
