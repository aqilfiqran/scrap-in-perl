#!/usr/bin/perl -w
use DateTime;
use strict;
use WWW::Mechanize;

# initialize modules and args
my $mech = WWW::Mechanize->new();
my $url;
my $time = DateTime->now();
my $directory = $ARGV[0] or die "\nDirectory belum diisi..\n"; #example : ./data not ./data/
my %hash;
my $syntax;
print "\ndalam proses ...\n";

my $count=7501;

my @links;
while(0 eq 0){
    # split to tekno and travel category
    if($count <=7500){
        $url="https://indeks.kompas.com/?site=travel&date=".$time->ymd('-');
    }
    else{
        if($count == 7500){
            $time = DateTime->now();
        }
        $url="https://www.tempo.co/indeks/".$time->ymd('/')."/tekno";
    }

    $mech->get($url);
    @links = $mech->links();
    # get HTML
    foreach my $link (@links) {
        # check duplicate url
        if(!exists($hash{$link->url})){
            $hash{$link->url} = 1;
            $syntax = "wget -O $directory/";

            if($link->url=~ /travel.kompas.com\/read/){
                $syntax.="travel$count.html --no-hsts ".$link->url;
            }elsif($link->url=~ /tekno.tempo.co\/read/){
                $syntax.="tekno".($count-7500).".html --no-hsts ".$link->url;
            }else{
                next;
            }

            `$syntax`;

            last if($count==15000);
            $count++;
        }
    }
    # check max size of page
    if($count == 15000){
        print "Program reach $count page\n";
        last;
    }
    # bring time to 1 day back
    $time = $time->add(days=>-1);
}
