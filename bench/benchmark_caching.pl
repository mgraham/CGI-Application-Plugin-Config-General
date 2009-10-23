#!/usr/bin/perl


use strict;
use warnings;
use lib '../lib';
use File::Temp qw(tempfile);
use File::Copy;

my ($first_fh, $first_conf_file)   = tempfile('tempconf_XXXXX', SUFFIX => '.conf');
my ($second_fh, $second_conf_file) = tempfile('tempconf_XXXXX', SUFFIX => '.conf');

use Benchmark;

{
    package WebAppOne;

    use base 'CGI::Application';
    use CGI::Application::Plugin::Config::General;

    sub setup {
        my $self = shift;

        $self->header_type('none');
        $self->run_modes(
            'start' => 'default',
        );
        $self->conf->init(
            -ConfigFile => $first_conf_file,
        );
    }

    sub default {
        '';
    }
}

{
    package WebAppTwo;

    use base 'CGI::Application';
    use CGI::Application::Plugin::Config::General;

    sub setup {
        my $self = shift;

        $self->header_type('none');
        $self->run_modes(
            'start' => 'default',
        );
        $self->conf->init(
            -ConfigFile       => $second_conf_file,
            -CacheConfigFiles => 0,
        );
    }

    sub default {
        '';
    }
}

sub with_caching {
    my $webapp = WebAppOne->new;
    $webapp->run;
}

sub without_caching {
    my $webapp = WebAppTwo->new;
    $webapp->run;
}


my $filename = shift or die "Usage: $0 configfile";

copy $filename, $first_conf_file;
copy $filename, $second_conf_file;

timethese(1000, {
    'with_caching'    => sub { with_caching()},
    'without_caching' => sub { without_caching()},
});

unlink $first_conf_file;
unlink $second_conf_file;
