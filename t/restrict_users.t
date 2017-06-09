
=head1 DESCRIPTION

This file tests the L<Igor::Runnable::RestrictUsers> role to ensure it
allows/denys users as appropriate.

=head1 SEE ALSO

L<Igor::Runnable::RestrictUsers>

=cut

use strict;
use warnings;
use Test::More;
use Test::Fatal;

my $USER = getpwuid( $> );
{ package
        t::RestrictUsers;
    use Moo;
    with 'Igor::Runnable', 'Igor::Runnable::RestrictUsers';
    sub run { $t::RestrictUsers::RAN++ }
}

subtest 'authorization failure' => sub {
    my $foo = t::RestrictUsers->new(
        authorized_users => [ ],
    );
    is exception { $foo->run }, "Unauthorized user: $USER\n",
        "user is not authorized";
    ok !$t::RestrictUsers::RAN, 'main code did not run';
};

subtest 'authorization success' => sub {
    my $foo = t::RestrictUsers->new(
        authorized_users => [ $USER ],
    );
    ok !exception { $foo->run }, "user is authorized";
    ok $t::RestrictUsers::RAN, 'main code ran';
    $t::RestrictUsers::RAN = 0;
};

done_testing;
