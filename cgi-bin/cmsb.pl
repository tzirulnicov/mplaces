#!/usr/bin/perl
use strict qw(subs vars);
use warnings;

use CGI::Carp 'fatalsToBrowser';

BEGIN
{
	require '/home/httpd/mplaces.ru/cmsbuilder/Config.pm';
}
use CMSBuilder::Starter;
CMSBuilder::Starter->start();

