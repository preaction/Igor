package Igor::Listener;
our $VERSION = '1.005';

use strict;
use warnings;

use Types::Standard qw(:all);
use Moo;

=attr code

A coderef which will be invoked when the event is distributed.

=cut

has callback => (
    is  => 'ro',
    isa => CodeRef,
    required => 1,
);

1;

__END__

=head1 SYNOPSIS

  package MyListener;

  extends 'Igor::Listener';


  # add metadata with subscription time
  has sub_time => is ( 'ro',
                        init_arg => undef,
                        default => sub { time() },
  );

   # My::Emitter consumes the Igor::Emitter role
   my $emitter = My::Emitter->new;
   $emitter->on( "foo", sub {
        my ( $event ) = @_;
        print "Foo happened!\n";
        # stop this event from continuing
        $event->stop;
    },
    class => MyListener
    );


=head1 DESCRIPTION

This is the base class used by C<Igor::Emitter> objects to store information
about listeners. Create a subclass to add data attributes.

=head1 SEE ALSO

=over 4

=item L<Igor::Emitter>

=back
