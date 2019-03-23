package Igor::Event::BuildService;
our $VERSION = '1.024';
# ABSTRACT: Event fired when building a new service

=head1 SYNOPSIS

    my $wire = Igor->new( ... );
    $wire->on( build_service => sub {
        my ( $event ) = @_;
        print "Built service named " . $event->service_name;
    } );

=head1 DESCRIPTION

This event is fired when a service is built. See
L<Igor/build_service>.

=head1 ATTRIBUTES

This class inherits from L<Igor::Event> and adds the following attributes.

=cut

use Moo;
use Types::Standard qw( Any Str );
extends 'Igor::Event';

=attr emitter

The container that is listening for the event.

=attr service_name

The name of the service being built.

=cut

has service_name => (
    is => 'ro',
    isa => Str,
);

=attr service

The newly-built service.

=cut

has service => (
    is => 'ro',
    isa => Any,
);

1;
