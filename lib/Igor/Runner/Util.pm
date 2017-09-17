package Igor::Runner::Util;
our $VERSION = '0.015';
# ABSTRACT: Utilities for Igor::Runner command classes

=head1 SYNOPSIS

    use Igor::Runner::Util qw( find_container_path );

    my $path = find_container_path( $container_name );

=head1 DESCRIPTION

This module has some shared utility functions for creating
L<Igor::Runner::Command> classes.

=head1 SEE ALSO

L<Igor::Runner>, L<igor>, L<Exporter>

=cut

use strict;
use warnings;
use Exporter 'import';
use Path::Tiny qw( path );

our @EXPORT_OK = qw( find_container_path find_containers );

# File extensions to try to find, starting with no extension (which is
# to say the extension is given by the user's input)
our @EXTS = ( "", qw( .yml .yaml .json .xml .pl ) );
# A regex to use to remove the container's name
my $EXT_RE = qr/(?:@{[ join '|', @EXTS ]})$/;

# The "IGOR_PATH" separator value. Windows uses ';' to separate
# PATH-like variables, everything else uses ':'
our $PATHS_SEP = $^O eq 'MSWin32' ? ';' : ':';

=sub find_containers

    my %container = find_containers();

Returns a list of C<name> and C<path> pairs pointing to all the containers
in the C<IGOR_PATH> paths.

=cut

sub find_containers {
    my %containers;
    for my $dir ( split /:/, $ENV{IGOR_PATH} ) {
        my $p = path( $dir );
        my $i = $p->iterator( { recurse => 1, follow_symlinks => 1 } );
        while ( my $file = $i->() ) {
            next unless $file->is_file;
            next unless $file =~ $EXT_RE;
            my $name = $file->relative( $p );
            $name =~ s/$EXT_RE//;
            $containers{ $name } ||= $file;
        }
    }
    return %containers;
}

=sub find_container_path

    my $path = find_container_path( $container_name );

Find the path to the given container. If the given container is already
an absolute path, it is simply returned. Otherwise, the container is
searched for in the directories defined by the C<IGOR_PATH> environment
variable.

If the container cannot be found, throws an exception with a user-friendly
error message.

=cut

sub find_container_path {
    my ( $container ) = @_;
    my $path;
    if ( path( $container )->is_file ) {
        return path( $container );
    }

    my @dirs = ( "." );
    if ( $ENV{IGOR_PATH} ) {
        push @dirs, split /$PATHS_SEP/, $ENV{IGOR_PATH};
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
        $container, join( $PATHS_SEP, @dirs )
        unless $path;

    return $path;
}

1;
