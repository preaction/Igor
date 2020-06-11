
=head1 DESCRIPTION

This file tests the L<Igor::Runner::Util> utility functions

=cut

use strict;
use warnings;
use Test::More;
use Test::Fatal;
use FindBin qw( $Bin );
use Igor::Runner::Util qw( find_containers );

subtest 'find_containers' => sub {

    subtest 'blank does not warn' => sub {
        local $ENV{IGOR_PATH};
        my @warnings;
        local $SIG{__WARN__} = sub { push @warnings, @_ };
        my %containers = find_containers();
        ok !@warnings, 'missing IGOR_PATH does not warn'
            or diag "Got warnings: \n- " . join "\n- ", @warnings;
    };

    local $ENV{IGOR_PATH} = $Bin . '/share';
    my %containers = find_containers();
    is_deeply \%containers, {
        empty => $Bin . '/share/empty.yml',
        undocumented => $Bin . '/share/undocumented.yml',
        container => $Bin . '/share/container.yml',
    }, 'containers are complete and correct';
};

done_testing;
