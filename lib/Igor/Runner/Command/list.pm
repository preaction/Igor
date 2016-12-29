package Igor::Runner::Command::list;
our $VERSION = '0.003';
# ABSTRACT: List the available containers and services

=head1 SYNOPSIS

    igor list
    igor list <container>

=head1 DESCRIPTION

List the available containers found in the directories defined in
C<IGOR_PATH>, or list the runnable services found in the given
container.

When listing services, this command must load every single class
referenced in the container, but it will not instanciate any object.

=head1 SEE ALSO

L<igor>, L<Igor::Runner::Command>, L<Igor::Runner>

=cut

use strict;
use warnings;
use List::Util qw( any max );
use Path::Tiny qw( path );
use Module::Runtime qw( use_module );
use Igor;
use Igor::Runner::Util qw( find_container_path );
use Pod::Find qw( pod_where );
use Pod::Simple::SimpleTree;

# The extensions to remove to show the container's name
my @EXTS = grep { $_ } @Igor::Runner::Util::EXTS;
# A regex to use to remove the container's name
my $EXT_RE = qr/(?:@{[ join '|', @EXTS ]})$/;

=method run

    my $exit = $class->run;
    my $exit = $class->run( $container );

Print the list of containers to C<STDOUT>, or, if C<$container> is given,
print the list of runnable services. A runnable service is an object
that consumes the L<Igor::Runnable> role.

=cut

sub run {
    my ( $class, $container ) = @_;

    if ( !$container ) {
        return $class->_list_containers;
    }
    return $class->_list_services( $container );
}

#=sub _list_containers
#
#   my $exit = $class->_list_containers
#
# Print all the containers found in the IGOR_PATH to STDOUT
#
#=cut

sub _list_containers {
    my ( $class ) = @_;
    die "Cannot list containers: IGOR_PATH environment variable not set\n"
        unless $ENV{IGOR_PATH};

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

    my @container_names = sort keys %containers;
    for my $i ( 0..$#container_names ) {
        $class->_list_services( $containers{ $container_names[ $i ] } );
        print "\n" unless $i == $#container_names;
    }

    return 0;
}

#=sub _list_services
#
#   my $exit = $class->_list_services( $container );
#
# Print all the runnable services found in the container to STDOUT
#
#=cut

sub _list_services {
    my ( $class, $container ) = @_;
    my $path = find_container_path( $container );
    my $cname = $path->basename( @EXTS );
    my $wire = Igor->new(
        file => $path,
    );
    print "$cname -- " . ( $wire->get( '$summary' ) || '' ) . "\n";

    my $config = $wire->config;
    my %services;
    for my $name ( keys %$config ) {
        my ( $name, $abstract ) = _list_service( $wire, $name, $config->{$name} );
        next unless $name;
        $services{ $name } = $abstract;
    }
    my $size = max map { length } keys %services;
    print join( "\n", map { sprintf "- %-${size}s -- %s", $_, $services{ $_ } } sort keys %services ), "\n";
    return 0;
}

#=sub _list_service
#
#   my $service_info = _list_service( $wire, $name, $config );
#
# If the given service is a runnable service, return the information
# about it ready to be printed to STDOUT. $wire is a Igor object,
# $name is the name of the service, $config is the service's
# configuration hash
#
#=cut

sub _list_service {
    my ( $wire, $name, $svc ) = @_;

    # If it doesn't look like a service, we don't care
    return unless $wire->is_meta( $svc, 1 );

    # Service hashes should be loaded and printed
    my %meta = $wire->get_meta_names;

    # Services that are just references to other services should still
    # be available under their referenced name
    my %svc = %{ $wire->normalize_config( $svc ) };
    if ( $svc{ ref } ) {
        my $ref_svc = $wire->get_config( $svc{ ref } );
        return _list_service( $wire, $name, $ref_svc );
    }

    # Services that extend other services must be resolved to find their
    # class and roles
    my %merged = $wire->merge_config( %svc );
    #; use Data::Dumper;
    #; print "$name merged: " . Dumper \%merged;
    my $class = $merged{ class };
    my @roles = @{ $merged{ with } || [] };

    # Can we determine this object is runnable without loading anything?
    if ( grep { $_ eq 'Igor::Runnable' } @roles ) {
        return _get_service_info( $name, $class );
    }

    if ( eval { any {; use_module( $_ )->DOES( 'Igor::Runnable' ) } $class, @roles } ) {
        return _get_service_info( $name, $class );
    }

    return;
}

#=sub _get_service_info( $name, $class )
#
#   my ( $name, $abstract ) = _get_service_info( $name, $class );
#
# Get the information about the given service. Opens the C<$class>
# documentation to find the class's abstract (the C<=head1 NAME>
# section).
#
#=cut

sub _get_service_info {
    my ( $name, $class ) = @_;
    my $pod_path = pod_where( { -inc => 1 }, $class );
    my $pod_root = Pod::Simple::SimpleTree->new->parse_file( $pod_path )->root;
    #; use Data::Dumper;
    #; print Dumper $pod_root;
    my @nodes = @{$pod_root}[2..$#$pod_root];
    #; print Dumper \@nodes;
    my ( $name_i ) = grep { $nodes[$_][0] eq 'head1' && $nodes[$_][2] eq 'NAME' } 0..$#nodes;
    my $abstract = $nodes[ $name_i + 1 ][2];
    return $name, $abstract;
}

1;


