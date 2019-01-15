package Igor::Runnable::AllowUsers;
our $VERSION = '0.016';
# ABSTRACT: Only allow certain users to run a command

=head1 SYNOPSIS

    ### In a Runnable module
    package My::Runnable::Script;
    use Moo;
    with 'Igor::Runnable', 'Igor::Runnable::AllowUsers';
    has '+allow_users' => ( default => [ 'root' ] );
    sub run { }

    ### In a container config file
    runnable:
        $class: My::Runnable::Script
        $with:
            - 'Igor::Runnable::AllowUsers'
        allow_users:
            - root
            - doug

=head1 DESCRIPTION

This role checks to ensure that only certain users can run a command. If
an unauthorized user runs the command, it dies with an error instead.

B<NOTE:> This is mostly a demonstration of a L<Igor::Runnable> role.
Users that can write to the configuration file can edit who is allowed
to run the command, and there are other ways to prevent access to
a file/command.

=head1 SEE ALSO

L<Igor::Runnable>, L<perlfunc/getpwuid>, L<< perlvar/$> >>

=cut

use strict;
use warnings;
use Moo::Role;
use List::Util qw( any );
use Types::Standard qw( ArrayRef Str );

=attr allow_users

An array reference of user names that are allowed to run this task.

=cut

has allow_users => (
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
        unless any { $_ eq $user } @{ $self->allow_users };
};

1;
