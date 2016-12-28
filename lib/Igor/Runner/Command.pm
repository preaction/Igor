package Igor::Runner::Command;
our $VERSION = '0.003';
# ABSTRACT: Main command handler delegating to individual commands

=head1 SYNOPSIS

    exit Igor::Runner::Command->run( $cmd => @args );

=head1 DESCRIPTION

This is the entry point for the L<igor> command which loads and
runs the specific C<Igor::Runner::Command> class.

=head1 SEE ALSO

The L<Igor::Runner> commands: L<Igor::Runner::Command::run>,
L<Igor::Runner::Command::list>, L<Igor::Runner::Command::help>

=cut

use strict;
use warnings;
use Module::Runtime qw( use_module compose_module_name );

sub run {
    my ( $class, $cmd, @args ) = @_;
    my $cmd_class = compose_module_name( 'Igor::Runner::Command', $cmd );
    return use_module( $cmd_class )->run( @args );
}

1;

