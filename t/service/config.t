
use Test::More;
use Test::Deep;
use Test::Exception;
use Test::Lib;
use Igor;
use Path::Tiny qw( path tempdir cwd );
use FindBin qw( $Bin );
my $SHARE_DIR = path( $Bin, '..', 'share' );

my $EXPECT = {
    foo => 'bar',
    baz => [qw( 1 2 3 )],
    obj => {
        # References do not get resolved by $config
        '$class' => 'Igor',
        '$args' => {
            services => {
                foo => 'bar',
            },
        },
    },
};

subtest 'yaml config file' => sub {
    my $wire = Igor->new(
        config => {
            yaml => {
                config => $SHARE_DIR->child( 'config', 'config.yml' )->stringify,
            },
        },
    );

    my $svc;
    lives_ok { $svc = $wire->get( 'yaml' ) };
    cmp_deeply $svc, $EXPECT;

    subtest 'config is relative to container file location' => sub {
        my $wire = Igor->new(
            file => $SHARE_DIR->child( 'with_config.yml' )->relative( cwd )->stringify,
        );

        my $svc;
        lives_ok { $svc = $wire->get( 'yaml' ) };
        cmp_deeply $svc, $EXPECT;
    };

    subtest 'absolute path works' => sub {
        my $wire = Igor->new(
            file => $SHARE_DIR->child( 'with_config.yml' )->stringify,
        );

        my $svc;
        lives_ok { $svc = $wire->get( 'yaml' ) };
        cmp_deeply $svc, $EXPECT;
    };
};

done_testing;
