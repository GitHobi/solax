my $missingModul = "";

use strict;
use warnings;
use Time::Local;
use JSON;
# use LWP::Simple;
use LWP::UserAgent;
use URI::Escape;


eval "use JSON;1" or $missingModul .= "JSON ";

   
my  $url    ="http://11.11.11.1/api/realTimeData.htm";
   


my $ua = new LWP::UserAgent;
$ua->timeout(120);

my $request = new HTTP::Request('GET', $url);
my $response = $ua->request($request);
my $content = $response->content();
print $content . "\n";
print "------\n";

$content = $content =~ s/,,/,0,/gr;
$content = $content =~ s/,,/,0,/gr;

print $content . "\n";
print "------\n";


my $result = decode_json($content);

my @names;

for (my $i=0; $i <= 67; $i++) {
	$names[$i] = "?";
}

$names[0] = "PV - PV1 Current";
$names[1] = "PV - PV2 Current";
$names[2] = "PV - PV1 Voltage";
$names[3] = "PV - PV2 Voltage";
$names[11] = "PV - PV1 Input Power";
$names[12] = "PV - PV2 Input Power";



$names[4] = "Grid - Output Current";
$names[5] = "Grid - Network Voltage";
$names[6] = "Grid - Power";
$names[10] = "Grid - Feed in Power";
$names[50] = "Grid - Frequency";
$names[41] = "Grid - Exported";
$names[42] = "Grid - Imported";

$names[13] = "Battery Voltage";
$names[14] = "Dis/Charge Current";
$names[15] = "Battery Power";
$names[16] = "Battery Temperature";
$names[17] = "Remaining Capacity";

$names[8] = "Inverter Yield - Today";
$names[9] = "Inverter Yield - This Month";

$names[19] = "Battery Yield - Total";


for (my $i=0; $i <= 67; $i++) {
	if ( $result->{Data}[$i] != 0.0 ) 
	{
		print $i . " " . $names[$i] . ": " . $result->{Data}[$i] . "\n";
	}
}

print  "Status: " . $result->{Status} . "\n";