use File::Spec;
use File::Basename qw(dirname);
use YAML;
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $sites = do {
    local $/;
    YAML::LoadFile(File::Spec->catfile($basedir, 'config', 'sites.yaml'));
};
my ($address) = `ifconfig` =~ /
    en0: .*? inet \s (\d+\.\d+\.\d+\.\d+)
/xs;
my $dbpath;
if ( -d '/home/dotcloud/') {
    $dbpath = "/home/dotcloud/development.db";
} else {
    $dbpath = File::Spec->catfile($basedir, 'db', 'development.db');
}
+{
    app_url => "http://$address:5000",
    sites => $sites,
    'DBI' => [
        "dbi:SQLite:dbname=$dbpath",
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],
};
