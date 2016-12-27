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
    }

    die qq{Could not find container $container in directories .:$ENV{IGOR}}
        unless $path;

    my $wire = Igor->new(
        file => $path,
    );
    my $service = $wire->get( $service_name );
    return $service->run( @args );
}

1;

