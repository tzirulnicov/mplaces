# (с) Леонов П.А., 2005

package CMSBuilder::VType::timestamp;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::VType';
# Временная метка ####################################################

sub table_cre {'TIMESTAMP'}

1;