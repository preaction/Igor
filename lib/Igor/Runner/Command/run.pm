package Igor::Runner::Command::run;
our $VERSION = '0.001';
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

# File extensions to try to find, starting with no extension (which is
# to say the extension is given by the user's input)
my @EXTS = ( "", qw( .yml .yaml .json .xml .pl ) );

sub run {
    my ( $class, $container, $service_name, @args ) = @_;
    my $path;
    if ( path( $container )->is_file ) {
        $path = path( $container );
    }
    else {
        my @dirs = ( "." );
        if ( $ENV{IGOR_PATH} ) {
            push @dirs, split /:/, $ENV{IGOR_PATH};
        }

        DIR: for my $dir ( @dirs ) {
            my $d = path( $dir );
            for my $ext ( @EXTS ) {
                my $f = $d->child( $container . $ext );
                if ( $f->exists ) {
                    $path = $f;
                    last DIR;
                }
            }
        }

        die sprintf qq{Could not find container "%s" in directories: %s\n},
            $container, join( ":", @dirs )
            unless $path;
    }

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

