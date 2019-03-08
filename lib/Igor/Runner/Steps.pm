package Igor::Runner::Steps;
our $VERSION = '0.017';
# ABSTRACT: Run a series of steps

=head1 SYNOPSIS

    igor run <container> <service>

=head1 DESCRIPTION

This runnable module runs a series of other runnable modules in
sequence. If any module returns a non-zero value, the steps stop.

=head1 SEE ALSO

L<igor>, L<Igor::Runnable>

=cut

use Moo;
use warnings;
with 'Igor::Runnable';
use Types::Standard qw( ArrayRef ConsumerOf );

=attr steps

The steps to run. Must be an arrayref of L<Igor::Runnable> objects.

=cut

has steps => (
    is => 'ro',
    isa => ArrayRef[ConsumerOf['Igor::Runnable']],
    required => 1,
);

sub run {
    my ( $self, @args ) = @_;
    for my $step ( @{ $self->steps } ) {
        my $exit = $step->run( @args );
        return $exit if $exit != 0;
    }
    return 0;
}

1;
