package Igor::Runnable::RestrictUsers;
our $VERSION = '0.012';
# ABSTRACT: Restrict the users that can run a command

=head1 SYNOPSIS

    ### In a Runnable module
    package My::Runnable::Script;
    use Moo;
    with 'Igor::Runnable', 'Igor::Runnable::RestrictUsers';
    has '+authorized_users' => ( default => [ 'root' ] );
    sub run { }

    ### In a container config file
    runnable:
        $class: My::Runnable::Script
        $with:
            - 'Igor::Runnable::RestrictUsers'
        authorized_users:
            - root
            - doug

=head1 DESCRIPTION

This role checks to ensure that only certain users can run a command. If an
unauthorized user runs the command, it dies with an error instead.

B<NOTE:> This is mostly a demonstration of a L<Igor::Runnable> role.
Users that can write to the configuration file can edit who is
authorized to run the command, and there are other ways to prevent
access to a file/command.

=head1 SEE ALSO

L<Igor::Runnable>, L<perlfunc/getpwuid>, L<< perlvar/$> >>

=cut

use strict;
use warnings;
use Moo::Role;
use List::Util qw( any );
use Types::Standard qw( ArrayRef Str );

=attr authorized_users

An array reference of user names that are authorized to run this task.

=cut

has authorized_users => (
    is => 'ro',
    isa => ArrayRef[ Str ],
    required => 1,
);

=method run

This role wraps the C<run> method of your runnable class to check that
the user is authorized.

=cut

before run => sub {
    my ( $self, @args ) = @_;
    my $user = getpwuid( $> );
    die "Unauthorized user: $user\n"
        unless any { $_ eq $user } @{ $self->authorized_users };
};

1;
