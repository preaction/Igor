package Igor::Event::ConfigService;
our $VERSION = '1.023';
# ABSTRACT: Event fired when configuring a new service

=head1 SYNOPSIS

    my $wire = Igor->new( ... );
    $wire->on( configure_service => sub {
        my ( $event ) = @_;
        print "Configuring service named " . $event->service_name;
    } );

=head1 DESCRIPTION

This event is fired when a service is configured. See
L<Igor/configure_service>.

=head1 ATTRIBUTES

This class inherits from L<Igor::Event> and adds the following attributes.

=cut

use Moo;
use Types::Standard qw( HashRef Str );
extends 'Igor::Event';

=attr emitter

The container that is listening for the event.

=attr service_name

The name of the service being configured.

=cut

has service_name => (
    is => 'ro',
    isa => Str,
);

=attr config

The normalized configuration for the service (see L<Igor/normalize_config>).

=cut

has config => (
    is => 'ro',
    isa => HashRef,
);

1;
