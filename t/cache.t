
use v5.20;
use warnings;
use File::Temp ();
use Cwd ();
use FindBin ();
use Test::More;
use Time::Piece ();
use Igor::Make::Cache;

my $cwd = Cwd::getcwd;
my $home = File::Temp->newdir();
chdir $home;

my $cache = Igor::Make::Cache->new( file => '.Igorfile.cache' );

# Each recipe controls how it identifies its data
my $dt = Time::Piece->new;
$cache->set( 'foo', 'abcdef', $dt );
ok -e '.Igorfile.cache', 'cache file is created';

is $cache->last_modified( foo => 'abcdef' ), $dt,
    'cache hit: hash match and last modified is correct';
is $cache->last_modified( foo => 'fedcba' ), 0,
    'cache miss: hash fail, last modified is 0';

# Reload cache from disk
$cache = Igor::Make::Cache->new;
is $cache->last_modified( foo => 'abcdef' ), $dt,
    'cache hit: hash match and last modified is correct';
is $cache->last_modified( foo => 'fedcba' ), 0,
    'cache miss: hash fail, last modified is 0';

chdir $cwd;
done_testing;
