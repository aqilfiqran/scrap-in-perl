#!/usr/bin/perl
use strict;
use warnings;
use HTML::ExtractContent;
use File::Basename;
use utf8;
# get directory and initialize modules
my $directory = $ARGV[0] or die "directory belum diisi"; #example : ./data not ./data/
my @files = `find $directory/*.html`;
my $extractor = HTML::ExtractContent->new;
# Directory where clean data are stored, its better to set this in config file
my $PATHCLEAN = "./clean";

print "On process get data from $ARGV[0] ...\n";
foreach my $file(@files){ 
    my $fileout = basename($file);

    $fileout = "$PATHCLEAN/$fileout";

    # open file
    open OUT, "> $fileout" or die "Cannot Open File!!!";
    binmode(OUT, "encoding(UTF-8)");

    my $html = `cat $file`;
    $html =~ s/\^M//g;

    # get URL
    if ($html =~ /property="og:url" content="(.*?)"/) {
        print OUT "<url>$1</url>\n";
    }

    # get TITLE
    if($html =~ /<title.*?>(.*?)<\/title>/){
        my $title = $1;

        $title = clean_str($title);
        print OUT "<title>$title</title>\n";
    }

    # get BODY (Content)
    $extractor->extract($html);
    my $content = $extractor->as_text;
    $content = clean_str($content);
    split_content($content);

    # close file
    close OUT;
}

print "\nSuccess...\n";

# split content to top, middle, and bottom
sub split_content{
    my @contents = split /\. /,$_[0];
    my $length = @contents;
    my $part = int($length/3);
    my $top='';
    my $middle='';
    my $bottom='';  
    if($part != 0){
        foreach my $i (0 .. $part){
            $top.=$contents[$i].'. ';
            $middle.=($i+$part)<$length? $contents[$i+$part].". ":'';
            $bottom.=($i+($part * 2))<$length? $contents[$i+($part * 2)].". ":'';
        }
            print OUT "<top>$top</top>\n";
            print OUT "<middle>$middle</middle>\n";
            print OUT "<bottom>$bottom</bottom>\n";
    }else{
        print OUT "<top>unknown</top>\n<middle>unknown</middle>\n<bottom>unknown</bottom>\n"
    }
}

# clean string using regex
sub clean_str {
    my $str = shift;
    $str =~ s/>//g;
    $str =~ s/&.*?;//g;
    $str =~ s/[\]\|\[\@\#\$\%\*\&\\\(\)\"]+//g;
    $str =~ s/-/ /g;
    $str =~ s/\n+//g;
    $str =~ s/\s+/ /g;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    $str =~ s/^$//g;
    return $str;
}
