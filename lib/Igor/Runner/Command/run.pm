package Igor::Runner::Command::run;
our $VERSION = '0.005';
# ABSTRACT: Run the given service with the given arguments

=head1 SYNOPSIS

    igor run <container> <service> [<args...>]

=head1 DESCRIPTION

Run a service from the given container, passing in any arguments.

=head1 SEE ALSO

L<igor>, L<Igor::Runner::Command>, L<Igor::Runner>

=cut

use strict;
use warnings;
use Igor;
use Path::Tiny qw( path );
use Scalar::Util qw( blessed );
use Igor::Runner::Util qw( find_container_path );

sub run {
    my ( $class, $container, $service_name, @args ) = @_;
    my $path = find_container_path( $container );
    my $wire = Igor->new(
        file => $path,
    );

    my $service = eval { $wire->get( $service_name ) };
    if ( $@ ) {
        if ( blessed $@ && $@->isa( 'Igor::Exception::NotFound' ) ) {
            die sprintf qq{Could not find service "%s" in container "%s"\n},
                $service_name, $path;
        }
        die $@;
    }

    return $service->run( @args );
}

1;

