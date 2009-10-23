
use strict;
use warnings;

use Test::More 'no_plan';

{
    package WebApp::Foo::Bar::Baz;
    use Test::More;

    use base 'CGI::Application';
    use CGI::Application::Plugin::Config::General;

    sub setup {
        my $self = shift;

        $self->header_type('none');
        $self->run_modes(
            'start' => 'default',
        );

        $ENV{'SCRIPT_NAME'} = '/tony';
        $ENV{'PATH_INFO'}   = '/baz';
        $ENV{'SITE_NAME'}   = 'fred';

        $self->conf('one')->init(
            -ConfigFile       => 't/conf/07-nested.conf',
            -CacheConfigFiles => 0,
        );

        $ENV{'SCRIPT_NAME'} = '/tony';
        $ENV{'PATH_INFO'}   = '/simon';
        $ENV{'SITE_NAME'}   = 'fred';

        $self->conf('two')->init(
            -ConfigFile       => 't/conf/07-nested.conf',
            -CacheConfigFiles => 0,
        );

        $ENV{'SCRIPT_NAME'} = '/tony';
        $ENV{'PATH_INFO'}   = '/simon';
        $ENV{'SITE_NAME'}   = 'wubba';

        $self->conf('three')->init(
            -ConfigFile       => 't/conf/07-nested.conf',
            -CacheConfigFiles => 0,
        );

        $ENV{'SCRIPT_NAME'} = '/baker';
        $ENV{'PATH_INFO'}   = '/fred';
        $ENV{'SITE_NAME'}   = 'gordon';

        $self->conf('four')->init(
            -ConfigFile       => 't/conf/07-nested.conf',
            -CacheConfigFiles => 0,
        );

        $ENV{'SCRIPT_NAME'} = '/tony';
        $ENV{'PATH_INFO'}   = '';
        $ENV{'SITE_NAME'}   = 'gordon';

        $self->conf('five')->init(
            -ConfigFile       => 't/conf/07-nested.conf',
            -CacheConfigFiles => 0,
        );

    }

    sub default {
        my $self = shift;

        my $config;

        # site=fred; loc=/tony/baz
        $config = $self->conf('one')->getall;
        is($config->{'foo'},             1,        '1.foo');
        is($config->{'gordon'},          0,        '1.gordon');
        is($config->{'/tony'},           1,        '1./tony');
        is($config->{'fred'},            1,        '1.fred');
        is($config->{'simon'},           0,        '1.simon');
        is($config->{'winner'},          'foo',    '1.winner');  # not longest, but most deeply nested
        is($config->{'location_winner'}, '/tony',  '1.location_winner');
        is($config->{'site_winner'},     'fred',   '1.site_winner');
        is($config->{'app_winner'},      'foo',    '1.app_winner');

        # site=wubba; loc=/tony/simon
        $config = $self->conf('three')->getall;
        is($config->{'foo'},             0,        '2.foo');
        is($config->{'gordon'},          0,        '2.gordon');
        is($config->{'/tony'},           1,        '2./tony');
        is($config->{'fred'},            0,        '2.fred');
        is($config->{'simon'},           0,        '2.simon');
        is($config->{'winner'},          '/tony',  '2.winner');
        is($config->{'location_winner'}, '/tony',  '2.location_winner');
        is($config->{'site_winner'},     'asdf',   '2.site_winner');
        is($config->{'app_winner'},      'asdf',   '2.app_winner');

        # site=gordon; loc=/baker/fred
        $config = $self->conf('four')->getall;
        is($config->{'foo'},             0,        '3.foo');
        is($config->{'gordon'},          0,        '3.gordon');
        is($config->{'/tony'},           0,        '3./tony');
        is($config->{'fred'},            0,        '3.fred');
        is($config->{'simon'},           0,        '3.simon');
        is($config->{'winner'},          'asdf',   '3.winner');
        is($config->{'location_winner'}, 'asdf',   '3.location_winner');
        is($config->{'site_winner'},     'asdf',   '3.site_winner');
        is($config->{'app_winner'},      'asdf',   '3.app_winner');

        # site=gordon; loc=/tony
        $config = $self->conf('five')->getall;
        is($config->{'foo'},             0,        '4.foo');
        is($config->{'gordon'},          1,        '4.gordon');
        is($config->{'/tony'},           1,        '4./tony');
        is($config->{'fred'},            0,        '4.fred');
        is($config->{'simon'},           0,        '4.simon');
        is($config->{'winner'},          'gordon', '4.winner');  # not longest or highest priority, but most deeply nested
        is($config->{'location_winner'}, '/tony',  '4.location_winner');
        is($config->{'site_winner'},     'gordon', '4.site_winner');
        is($config->{'app_winner'},      'asdf',   '4.app_winner');

        return "";
    }
}

my $webapp = WebApp::Foo::Bar::Baz->new;
$webapp->run;



