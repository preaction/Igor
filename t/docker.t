
use v5.20;
use warnings;
use File::Temp ();
use Cwd ();
use FindBin ();
use Test::More;
use File::Which qw( which );
use Igor::Make;
use Log::Any::Adapter Stderr => log_level => $ENV{HARNESS_IS_VERBOSE} ? 'debug' : 'fatal';

BEGIN {
    which 'docker'
        or plan skip_all => 'Could not find path to `docker` executable';
};

my $cwd = Cwd::getcwd;
my $home = File::Temp->newdir();
chdir $home;

# Place to look for container files
my $SHARE_DIR = $ENV{IGOR_PATH} = join '/', $FindBin::Bin, 'share';

my $make = Igor::Make->new(
    conf => {
        # Pull an image
        base => {
            '$class' => 'Igor::Make::Docker::Image',
            image => 'alpine:3.7',
        },

        # Make an image
        'image' => {
            '$class' => 'Igor::Make::Docker::Image',
            requires => [qw( base )],
            build => '$SHARE_DIR/docker',
            image => 'preaction/igor-make:test',
        },

        # Make a container
        'igor-make-test-container' => {
            '$class' => 'Igor::Make::Docker::Container',
            requires => [qw( image )],
            image => 'preaction/igor-make:test',
            volumes => [
                '$HOME/app',
            ],
            ports => [
                "5000:5000",
            ],
            restart => 'unless-stopped',
        },

    },
);

my $has_alpine = grep /^alpine\s+3\.7/, map { s/\n+//gr } `docker images`;
END {
    # Clean up everything we're about to create
    system 'docker', 'rm', 'igor-make-test-container';
    system 'docker', 'rmi', 'preaction/igor-make:test';
    if ( !$has_alpine ) {
        system 'docker', 'rmi', 'alpine:3.7';
    }
}

subtest 'make everything' => sub {
    $make->run( 'igor-make-test-container', "HOME=$home", "SHARE_DIR=$SHARE_DIR" );
    my @images = map { s/\n+//gr } `docker images`;
    ok +( grep /^alpine\s+3\.7\s+6d1ef012b567/, @images ),
        'alpine base image listed in local images';
    ok +( grep /^preaction\/igor-make\s+test/, @images ),
        'created image listed in local images';
    my @containers = map { s/\n+//gr } `docker ps -a`;
    ok +( grep /preaction\/igor-make\s+test/, @images ),
        'created container listed';
};

chdir $cwd;
done_testing;
