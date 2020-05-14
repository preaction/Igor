package Igor::Make::Recipe;
our $VERSION = '0.002';
# ABSTRACT: The base class for Igor::Make recipes

=head1 SYNOPSIS

    package My::Recipe;
    use v5.20;
    use Moo;
    use experimental qw( signatures );
    extends 'Igor::Make::Recipe';

    # Make the recipe
    sub make( $self ) {
        ...;
    }

    # Return a Time::Piece object for when this recipe was last
    # performed, or 0 if it can't be determined.
    sub last_modified( $self ) {
        ...;
    }

=head1 DESCRIPTION

This is the base L<Igor::Make> recipe class. Extend this to build your
own recipe components.

=head1 REQUIRED METHODS

=head2 make

This method performs the work of the recipe. There is no return value.

=head2 last_modified

This method returns a L<Time::Piece> object for when this recipe was last
performed, or C<0> otherwise. This method could use the L</cache> object
to read a cached date. See L<Igor::Make::Cache> for more information.

=head1 SEE ALSO

L<Igor::Make>

=cut

use v5.20;
use warnings;
use Moo;
use Time::Piece;
use experimental qw( signatures postderef );

=attr name

The name of the recipe. This is the key in the C<Igorfile> used to refer
to this recipe.

=cut

has name => ( is => 'ro', required => 1 );

=attr requires

An array of recipe names that this recipe depends on.

=cut

has requires => ( is => 'ro', default => sub { [] } );

=attr cache

A L<Igor::Make::Cache> object. This is used to store content hashes and
modified dates for later use.

=cut

has cache => ( is => 'ro', required => 1 );

=method fill_env

Fill in any environment variables in the given array of strings. Environment variables
are interpreted as a POSIX shell: C<< $name >> or C<< ${name} >>.

=cut

sub fill_env( $self, @ary ) {
    return map {
        defined $_ ?
            s{\$\{([^\}]+\})}{ $ENV{ $1 } // ( "\$$1" ) }egr
            =~ s{\$([a-zA-Z_][a-zA-Z0-9_]+)}{ $ENV{ $1 } // ( "\$$1" ) }egr
        : $_
     } @ary;
}

1;
