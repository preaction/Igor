package Igor::Runner::ExecCommand;
our $VERSION = '0.016';
# ABSTRACT: Run an external command

=head1 SYNOPSIS

    igor run <container> <service>

=head1 DESCRIPTION

This runnable module runs an external command using L<perlfunc/system>.

=head1 SEE ALSO

L<igor>, L<Igor::Runnable>

=cut

use Moo;
use warnings;
with 'Igor::Runnable';
use Types::Standard qw( Str ArrayRef );

=attr command

The command to run. If a string, will execute the command in a subshell.
If an arrayref, will execute the command directly without a subshell.

=cut

has command => (
    is => 'ro',
    isa => ArrayRef[Str]|Str,
    required => 1,
);

sub run {
    my ( $self, @args ) = @_;
    my $cmd = $self->command;
    my $exit;
    if ( ref $cmd eq 'ARRAY' ) {
        $exit = system @$cmd;
    }
    else {
        $exit = system $cmd;
    }
    if ( $exit == -1 ) {
        my $name = ref $cmd eq 'ARRAY' ? $cmd->[0] : $cmd;
        die "Error starting command %s: $!\n", $name;
    }
    elsif ( $exit & 127 ) {
        die sprintf "Command died with signal %d\n", ( $exit & 127 );
    }
    return $exit;
}

1;
