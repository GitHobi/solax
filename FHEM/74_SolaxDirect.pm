package main;

my $missingModul = "";

use strict;
use warnings;
use Time::Local;
use JSON;
use HttpUtils;
use Blocking;
use URI::Escape;


eval "use JSON;1" or $missingModul .= "JSON ";

my $version = "0.1";


##############################################################
#
# Declare functions
#
##############################################################

sub SolaxDirect_Initialize($);
sub SolaxDirect_Define($$);

sub SolaxDirect_Notify($$);

sub SolaxDirect_Attr(@);
sub SolaxDirect_Undef($$);

sub SolaxDirect_CONNECTED($@);
sub SolaxDirect_Get ($@);


##############################################################

sub SolaxDirect_Initialize($) {
	my ($hash) = @_;
	
    $hash->{DefFn}      = "SolaxDirect_Define";
    $hash->{UndefFn}    = "SolaxDirect_Undef";
    $hash->{NotifyFn} 	= "SolaxDirect_Notify";
    $hash->{AttrFn}     = "SolaxDirect_Attr";
	$hash->{GetFn}    = "SolaxDirect_Get";
    $hash->{AttrList}   = "interval " .
                          $readingFnAttributes;

    foreach my $d(sort keys %{$modules{SolaxDirect}{defptr}}) {
        my $hash = $modules{SolaxDirect}{defptr}{$d};
        $hash->{SolaxDirect}{version} = $version;
    }
	
	
	
	
}

sub
SolaxDirect_Get($@)
{
  my ($hash, @a) = @_;

  my $name = $a[0];
  return "$name: get needs at least one parameter" if(@a < 2);

  my $cmd= $a[1];

  my $ret = "";
  if( $cmd eq "json" ) 
  {
  	my $batteryPower = $hash->{SolaxDirect}->{battery_power};
	my $batteryPercent = $hash->{SolaxDirect}->{battery_remain_capacity};
	my $inverter_powerexported = $hash->{SolaxDirect}->{grid_feed_in_power};
	my $solar_power = $hash->{SolaxDirect}->{pv_total_power};
	my $powerHouse = $hash->{SolaxDirect}->{home_power};

	my $h = <<"END_TXT";
{
	"batteryPower":$batteryPower, 
	"batteryPercent":$batteryPercent, 
	"powerExported":$inverter_powerexported, 
	"powerSolar":$solar_power, 
	"powerHouse":$powerHouse
}	
END_TXT
	
	return $h;
  }

  return undef;
  return "Unknown argument $cmd, choose one of html:noArg";
}




sub SolaxDirect_Define($$){
    my ( $hash, $def ) = @_;
    my @a = split( "[ \t]+", $def );
    my $name = $a[0];

    return "too few parameters: define <NAME> SolaxDirect" if( @a < 1 ) ;
    return "Cannot define SolaxDirect device. Perl modul $missingModul is missing." if ( $missingModul );

    %$hash = (%$hash,
        NOTIFYDEV => "global,$name",
        SolaxDirect     => { 
            CONNECTED   			=> 0,
            version     			=> $version,
			battery_power		=> 0,
			battery_temperature		=> 0,
			battery_charge => 0,
            interval    			=> 60,
            expires 				=> time(),
        },
    );
	
	$attr{$name}{room} = "SolaxDirect" if( !defined( $attr{$name}{room} ) );
	
	SolaxDirect_CONNECTED($hash,'initialized');

	
	#SolaxDirect_FetchDataFromInverter ( $hash);
	
	return undef;

}


sub SolaxDirect_Notify($$) {
    
    my ($hash,$dev) = @_;
    my ($name) = ($hash->{NAME});
    
	if (AttrVal($name, "disable", 0)) {
		Log3 $name, 5, "Device '$name' is disabled, do nothing...";
		SolaxDirect_CONNECTED($hash,'disabled');
	    return undef;
    }

 	my $devname = $dev->{NAME};
    my $devtype = $dev->{TYPE};
    my $events = deviceEvents($dev,1);
	return if (!$events);
    
    $hash->{SolaxDirect}->{updateStartTime} = time();    
    
	Log3 $name, 3, "SolaxDirect: " . "notify $devtype"; 
	
    if ( $devtype eq 'Global') {
	    if (
	    	grep /^INITIALIZED$/,@{$events}
	    	or grep /^REREADCFG$/,@{$events}
	        or grep /^DEFINED.$name$/,@{$events}
	        or grep /^MODIFIED.$name$/,@{$events}
	    ) {
			Log3 $name, 3, "SolaxDirect: " . "notify trigger update"; 
	        SolaxDirect_FetchDataFromInverter($hash);
	    }
	} 
	
	if ( $devtype eq 'SolaxDirect') {
		#if ( grep(/^state:.authenticated$/, @{$events}) ) {
        	#SolaxDirect_FetchDataFromInverter($hash);
		#}
		
		#if ( grep(/^state:.connected$/, @{$events}) ) {
		#	SolaxDirect_FetchDataFromInverter($hash);
		#}
		#	
		#if ( grep(/^state:.disconnected$/, @{$events}) ) {
		 #   Log3 $name, 3, "Reconnecting...";
		#	SolaxDirect_FetchDataFromInverter($hash);
		#}
	}
    
    return undef;
}


sub SolaxDirect_Attr(@) {
	
    my ( $cmd, $name, $attrName, $attrVal ) = @_;
    my $hash = $defs{$name};
	
	Log3 $name, 3, "SolaxDirect: " . "attr $name $attrName $attrVal"; 
	
	if( $attrName eq "disable" ) {
        if( $cmd eq "set" and $attrVal eq "1" ) {
            RemoveInternalTimer($hash);
            readingsSingleUpdate ( $hash, "state", "disable", 1 );
            Log3 $name, 5, "$name - disabled";
        }

        elsif( $cmd eq "del" ) {
            readingsSingleUpdate ( $hash, "state", "active", 1 );
            Log3 $name, 5, "$name - enabled";
        }
    }
    


	elsif( $attrName eq "interval" ) {
        if( $cmd eq "set" ) {
            RemoveInternalTimer($hash);
            return "Interval must be greater than 0"  unless($attrVal > 0);
            $hash->{SolaxDirect}->{interval} = $attrVal;
            Log3 $name, 5, "$name - set interval: $attrVal";
        }

        elsif( $cmd eq "del" ) {
            RemoveInternalTimer($hash);
            $hash->{SolaxDirect}->{interval}   = 300;
            Log3 $name, 5, "$name - deleted interval and set to default: 300";
        }
    }

	
	
	
    return undef;
}


sub SolaxDirect_Undef($$){
	my ( $hash, $arg )  = @_;
    my $name            = $hash->{NAME};
    my $deviceId        = $hash->{DEVICEID};
    delete $modules{SolaxDirect}{defptr}{$deviceId};
    RemoveInternalTimer($hash);
    return undef;
}


sub SolaxDirect_Set($@){
	my ($hash,@a) = @_;
    return "\"set $hash->{NAME}\" needs at least an argument" if ( @a < 2 );
    my ($name,$setName,$setVal,$setVal2,$setVal3) = @a;

	Log3 $name, 3, "$name: set called with $setName " . ($setVal ? $setVal : "") if ($setName ne "?");

	if (SolaxDirect_CONNECTED($hash) eq 'disabled' && $setName !~ /clear/) {
        return "Unknown argument $setName, choose one of clear:all,readings";
        Log3 $name, 3, "$name: set called with $setName but device is disabled!" if ($setName ne "?");
        return undef;
    }

    if ($setName !~ /start|stop|park|update/) {
        return "Unknown argument $setName, choose one of start stop park update";
	}
	
	if ($setName eq 'update') {
        RemoveInternalTimer($hash);
        #SolaxDirect_DoUpdate($hash);
    }
    
	
	
    return undef;

}



sub SolaxDirect_FetchDataFromInverter($) {
    my ($hash, $def) = @_;
    my $name = $hash->{NAME};
    
	#Log3 $name, 3, "SolaxDirect: " . "fetchData $name"; 
	
    my $header = "Content-Type: application/json\r\nAccept: application/json";
    HttpUtils_NonblockingGet({
        url        	=> "http://11.11.11.1/api/realTimeData.htm",
        timeout    	=> 120,
        hash       	=> $hash,
        method     	=> "GET",
        header     	=> $header, 		
        callback   	=> \&SolaxDirect_FetchDataFromInverterResponse,
    });  
    
	SolaxDirect_CONNECTED($hash,'OK');
	
	return undef;
	
}


sub SolaxDirect_FetchDataFromInverterResponse($) {
    my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

	#Log3 $name, 3, "SolaxDirect: " . "fetchDataResp $name"; 
	
    if($err ne "") {
        Log3 $name, 3, "error while requesting ".$param->{url}." - $err";     
    } elsif($data ne "") {
	    
		
		$data = $data =~ s/,,/,0,/gr;
		$data = $data =~ s/,,/,0,/gr;

		my $result = decode_json($data);
	   
	        #Log3 $name, 3, "SolaxDirect: " . "$data"; 
			
			
			$hash->{SolaxDirect}->{pv_pv1_current} = $result->{Data}[0];
			$hash->{SolaxDirect}->{pv_pv2_current} = $result->{Data}[1];
			$hash->{SolaxDirect}->{pv_pv1_voltage} = $result->{Data}[2];
			$hash->{SolaxDirect}->{pv_pv2_voltage} = $result->{Data}[3];
			$hash->{SolaxDirect}->{pv_pv1_power} = $result->{Data}[11];
			$hash->{SolaxDirect}->{pv_pv2_power} = $result->{Data}[12];
			$hash->{SolaxDirect}->{pv_total_power} = $result->{Data}[11] + $result->{Data}[12];
			
			
		
			$hash->{SolaxDirect}->{grid_output_current} = $result->{Data}[4];
			$hash->{SolaxDirect}->{grid_network_voltage} = $result->{Data}[5];
			$hash->{SolaxDirect}->{grid_power} = $result->{Data}[6];
			$hash->{SolaxDirect}->{grid_feed_in_power} = $result->{Data}[10];
			$hash->{SolaxDirect}->{grid_frequency} = $result->{Data}[50];
			$hash->{SolaxDirect}->{grid_exported} = $result->{Data}[41];
			$hash->{SolaxDirect}->{grid_imported} = $result->{Data}[42];
			
			
			$hash->{SolaxDirect}->{battery_voltage} = $result->{Data}[13];
			$hash->{SolaxDirect}->{battery_power} = $result->{Data}[15];
			$hash->{SolaxDirect}->{battery_temperature} = $result->{Data}[16];
			$hash->{SolaxDirect}->{battery_charge} = $result->{Data}[14];
			$hash->{SolaxDirect}->{battery_remain_capacity} = $result->{Data}[17];
			
			$hash->{SolaxDirect}->{inverter_yield_today} = $result->{Data}[8];
			$hash->{SolaxDirect}->{inverter_yield_month} = $result->{Data}[9];
			$hash->{SolaxDirect}->{battery_yield_total} = $result->{Data}[19];
			
			$hash->{SolaxDirect}->{home_power} = $hash->{SolaxDirect}->{grid_power} - $hash->{SolaxDirect}->{grid_feed_in_power} ;
			
			
			# set Readings	
			readingsBeginUpdate($hash);
			
			readingsBulkUpdate($hash,'pv_pv1_current',$hash->{SolaxDirect}->{pv_pv1_current} );
			readingsBulkUpdate($hash,'pv_pv2_current',$hash->{SolaxDirect}->{pv_pv2_current} );
			readingsBulkUpdate($hash,'pv_pv1_voltage',$hash->{SolaxDirect}->{pv_pv1_voltage} );
			readingsBulkUpdate($hash,'pv_pv2_voltage',$hash->{SolaxDirect}->{pv_pv2_voltage} );
			readingsBulkUpdate($hash,'pv_pv1_power',$hash->{SolaxDirect}->{pv_pv1_power} );
			readingsBulkUpdate($hash,'pv_pv2_power',$hash->{SolaxDirect}->{pv_pv2_power} );
			readingsBulkUpdate($hash,'pv_total_power',$hash->{SolaxDirect}->{pv_total_power} );
			
			readingsBulkUpdate($hash,'battery_power',$hash->{SolaxDirect}->{battery_power} );
			readingsBulkUpdate($hash,'battery_temperature',$hash->{SolaxDirect}->{battery_temperature} );
			readingsBulkUpdate($hash,'battery_charge',$hash->{SolaxDirect}->{battery_charge} );
			readingsBulkUpdate($hash,'battery_voltage',$hash->{SolaxDirect}->{battery_voltage} );
			readingsBulkUpdate($hash,'battery_remain_capacity',$hash->{SolaxDirect}->{battery_remain_capacity} );
			
			readingsBulkUpdate($hash,'inverter_yield_today',$hash->{SolaxDirect}->{inverter_yield_today} );
			readingsBulkUpdate($hash,'inverter_yield_month',$hash->{SolaxDirect}->{inverter_yield_month} );
			readingsBulkUpdate($hash,'battery_yield_total',$hash->{SolaxDirect}->{battery_yield_total} );
			
			readingsBulkUpdate($hash,'grid_output_current',$hash->{SolaxDirect}->{grid_output_current} );
			readingsBulkUpdate($hash,'grid_network_voltage',$hash->{SolaxDirect}->{grid_network_voltage} );
			readingsBulkUpdate($hash,'grid_power',$hash->{SolaxDirect}->{grid_power} );
			readingsBulkUpdate($hash,'grid_feed_in_power',$hash->{SolaxDirect}->{grid_feed_in_power} );
			readingsBulkUpdate($hash,'grid_frequency',$hash->{SolaxDirect}->{grid_frequency} );
			readingsBulkUpdate($hash,'grid_exported',$hash->{SolaxDirect}->{grid_exported} );
			readingsBulkUpdate($hash,'grid_imported',$hash->{SolaxDirect}->{grid_imported} );
			
			readingsBulkUpdate($hash,'home_power',$hash->{SolaxDirect}->{home_power} );
			
			readingsEndUpdate($hash, 1);
			
			#Log3 $name, 3, "SolaxDirect: " . "data updated"; 
	    
    }
	
	InternalTimer( time() + $hash->{SolaxDirect}->{interval}, "SolaxDirect_FetchDataFromInverter", $hash, 0 );

	#Log3 $name, 3, "SolaxDirect: " . "done"; 
	
	return undef;
}




sub SolaxDirect_CONNECTED($@) {
	my ($hash,$set) = @_;
    if ($set) {
	  $hash->{SolaxDirect}->{CONNECTED} = $set;
       RemoveInternalTimer($hash);
       %{$hash->{updateDispatch}} = ();
       if (!defined($hash->{READINGS}->{state}->{VAL}) || $hash->{READINGS}->{state}->{VAL} ne $set) {
       		readingsSingleUpdate($hash,"state",$set,1);
       }
	   return undef;
	} else {
		if ($hash->{SolaxDirect}->{CONNECTED} eq 'disabled') {
            return 'disabled';
        }
        elsif ($hash->{SolaxDirect}->{CONNECTED} eq 'connected') {
            return 1;
        } else {
            return 0;
        }
	}
}


