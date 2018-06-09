###############################################################################
# 
#  (c) 2018 Copyright: Dr. Dennis Krannich (blog at krannich dot de)
#  All rights reserved
#
#  This script is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#
#  The GNU General Public License can be found at
#  http://www.gnu.org/copyleft/gpl.html.
#  A copy is found in the textfile GPL.txt and important notices to the license
#  from the author is found in LICENSE.txt distributed with these scripts.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#
# $Id: 74_SolaxHybrid.pm 0 2018-01-27 12:00:00Z krannich $
#  
################################################################################

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

use constant SOLAXAPIURL => "http://www.solax-portal.com/api/v1";


##############################################################
#
# Declare functions
#
##############################################################

sub SolaxHybrid_Initialize($);
sub SolaxHybrid_Define($$);

sub SolaxHybrid_Notify($$);

sub SolaxHybrid_Attr(@);
sub SolaxHybrid_Set($@);
sub SolaxHybrid_Undef($$);

sub SolaxHybrid_CONNECTED($@);
sub SolaxHybrid_CMD($$);
sub SolaxHybrid_Get ($@);


##############################################################

sub SolaxHybrid_Initialize($) {
	my ($hash) = @_;
	
    #$hash->{SetFn}      = "SolaxHybrid_Set";
    $hash->{DefFn}      = "SolaxHybrid_Define";
    $hash->{UndefFn}    = "SolaxHybrid_Undef";
    $hash->{NotifyFn} 	= "SolaxHybrid_Notify";
    $hash->{AttrFn}     = "SolaxHybrid_Attr";
	$hash->{GetFn}    = "SolaxHybrid_Get";
    $hash->{AttrList}   = "username " .
                          "password " .
                          "interval " .
                          $readingFnAttributes;

    foreach my $d(sort keys %{$modules{SolaxHybrid}{defptr}}) {
        my $hash = $modules{SolaxHybrid}{defptr}{$d};
        $hash->{SolaxHybrid}{version} = $version;
    }
	
	$hash->{FW_detailFn} = "SolaxHybrid_FhemWebCallback";

	
	
}

sub
SolaxHybrid_Get($@)
{
  my ($hash, @a) = @_;

  my $name = $a[0];
  return "$name: get needs at least one parameter" if(@a < 2);

  my $cmd= $a[1];

  my $ret = "";
  if( $cmd eq "json" ) 
  {
		
	my $batteryPower = $hash->{SolaxHybrid}->{battery_power};
	my $batteryPercent = $hash->{SolaxHybrid}->{battery_percent};
	my $inverter_powerexported = $hash->{SolaxHybrid}->{inverter_data_powerexported};
	my $solar_power = $hash->{SolaxHybrid}->{inverter_data_powerinputTotal};
	my $powerHouse = $hash->{SolaxHybrid}->{inverter_data_powernow} - $inverter_powerexported;

		my $h = <<"END_TXT";
{"batteryPower":$batteryPower, "batteryPercent":$batteryPercent, "powerExported":$inverter_powerexported, "powerSolar":$solar_power, "powerHouse":$powerHouse}	
END_TXT
	
	return $h;
  }

  return undef;
  return "Unknown argument $cmd, choose one of html:noArg";
}


sub SolaxHybrid_FhemWebCallback ($$)
{
	my ($FW_wname, $d, $room, $pageHash) = @_; # pageHash is set for summaryFn.
	my $hash   = $defs{$d};
	
my $h = <<'END_TXT';
	    <link href="$FW_ME/Solax/style.css" rel="stylesheet" type="text/css">
		<div style="background-color:transparent;position:relative;width:400px;height:350px;">
			<div style="position:absolute;top:145px;left:150px; background:url($FW_ME/Solax/home-load-power.png) no-repeat;background-size:100%;width:100px;height:140px;">
				<div id="home" class="innerText">$powerHouseW</div>
			</div>
			<div style="position:absolute;top:10px;left:150px; background:url($FW_ME/Solax/home-pv.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="solar" class="innerText2">$powerInputTotalW</div>
	</div>

	<div style="position:absolute;top:195px;left:273px; background:url($FW_ME/Solax/$batteryImage.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="battery" class="innerText $batteryLoading">$batter_powerW</div>
		<div id="batteryPercent" class="innerText $batteryLoading" style="top:80px;font-size:8px;">$battery_powerP%</div>
	</div>

	<div style="position:absolute;top:195px;left:25px; background:url($FW_ME/Solax/home-grid.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="grid" class="innerText $powerExporting">$powerExportedW</div>
	</div>


	<div style="position:absolute;top:118px;left:195px; background:url($FW_ME/Solax/s2-$flowS2.gif) no-repeat;background-size:100%;width:10px;height:60px;"></div>
	<div style="position:absolute;top:200px;left:250px; background:url($FW_ME/Solax/s5-$flowS5.gif) no-repeat;background-size:100%;width:27px;height:60px;"></div>
	<div style="position:absolute;top:200px;left:120px; background:url($FW_ME/Solax/s4-$flowS4.gif) no-repeat;background-size:100%;width:27px;height:60px;"></div>


	<div id="loadBattery" style="position:absolute;top:70px;left:255px; background:url($FW_ME/Solax/s3-$flowS3.gif) no-repeat;background-size:100%;width:80px;height:200px;"></div>
	<div style="position:absolute;top:285px;left:110px; background:url($FW_ME/Solax/s6-0.gif) no-repeat;background-size:100%;width:180px;height:60px;"></div>
	<div style="position:absolute;top:70px;left:65px; background:url($FW_ME/Solax/s1-$flowS1.gif) no-repeat;background-size:100%;width:80px;height:200px;"></div>
		</div>
END_TXT

	
	$h =~ s/\$FW_ME/$FW_ME/g;
	
	my $batteryPower = $hash->{SolaxHybrid}->{battery_power};
	my $batteryPercent = $hash->{SolaxHybrid}->{battery_percent};
	my $inverter_powerexported = $hash->{SolaxHybrid}->{inverter_data_powerexported};
	my $solar_power = $hash->{SolaxHybrid}->{inverter_data_powerinputTotal};
	
	my $powerHouse = $hash->{SolaxHybrid}->{inverter_data_powernow} - $inverter_powerexported;
	
	$h =~ s/\$batter_power/$batteryPower/g;
	$h =~ s/\$battery_powerP/$batteryPercent/g;
	$h =~ s/\$powerInputTotal/$solar_power/g;
	$h =~ s/\$powerExported/$inverter_powerexported/g;
	$h =~ s/\$powerHouse/$powerHouse/g;
	
	if ( $solar_power > 0 )
	{
		$h =~ s/\$flowS2/1/g;
	}
	else
	{
		$h =~ s/\$flowS2/0/g;
	}
	
	
	$h =~ s/\$flowS5/0/g unless $batteryPower<0;
	$h =~ s/\$flowS5/2/g unless $batteryPower>=0;
	
	if ( $batteryPower > 0 )
	{
		$h =~ s/\$batteryLoading/green/g;
		$h =~ s/\$flowS3/1/g;
		
	}
	else
	{
        $h =~ s/\$batteryLoading/red/g;
		$h =~ s/\$flowS3/0/g;
		
	}
	
	if ( $inverter_powerexported > 0 )
	{
		$h =~ s/\$powerExporting/green/g;
		$h =~ s/\$flowS4/0/g;
		$h =~ s/\$flowS1/1/g;
	}
	else
	{
		$h =~ s/\$powerExporting/red/g;
		$h =~ s/\$flowS4/2/g;
		$h =~ s/\$flowS1/0/g;
	}
	
	if ( $batteryPercent < 30 )
	{
		$h =~ s/\$batteryImage/home-battery-power1/g;
	}
	
	if ( $batteryPercent < 60 )
	{
		$h =~ s/\$batteryImage/home-battery-power2/g;
	}
	 
	 
	 if ( $batteryPercent < 85 )
	{
		$h =~ s/\$batteryImage/home-battery-power3/g;
	}
	
	$h =~ s/\$batteryImage/home-battery-power4/g;
	
	
	
	#return "<img src=".$FW_ME."/Solax/home-pv.png>";
	return $h;
}

sub SolaxHybrid_Define($$){
    my ( $hash, $def ) = @_;
    my @a = split( "[ \t]+", $def );
    my $name = $a[0];

    return "too few parameters: define <NAME> SolaxHybrid" if( @a < 1 ) ;
    return "Cannot define SolaxHybrid device. Perl modul $missingModul is missing." if ( $missingModul );

    %$hash = (%$hash,
        NOTIFYDEV => "global,$name",
        SolaxHybrid     => { 
            CONNECTED   			=> 0,
            version     			=> $version,
            token					=> '',
            provider				=> '',
            user_id					=> '',
            username 				=> '',
            password 				=> '',
			battery_percent		=> 0,
			battery_power		=> 0,
            interval    			=> 300,
            expires 				=> time(),
        },
    );
	
	$attr{$name}{room} = "SolaxHybrid" if( !defined( $attr{$name}{room} ) );
	
	SolaxHybrid_CONNECTED($hash,'initialized');

	
	SolaxHybrid_APIAuth ( $hash);
	
	return undef;

}


sub SolaxHybrid_Notify($$) {
    
    my ($hash,$dev) = @_;
    my ($name) = ($hash->{NAME});
    
	if (AttrVal($name, "disable", 0)) {
		Log3 $name, 5, "Device '$name' is disabled, do nothing...";
		SolaxHybrid_CONNECTED($hash,'disabled');
	    return undef;
    }

 	my $devname = $dev->{NAME};
    my $devtype = $dev->{TYPE};
    my $events = deviceEvents($dev,1);
	return if (!$events);
    
    $hash->{SolaxHybrid}->{updateStartTime} = time();    
    
    if ( $devtype eq 'Global') {
	    if (
	    	grep /^INITIALIZED$/,@{$events}
	    	or grep /^REREADCFG$/,@{$events}
	        or grep /^DEFINED.$name$/,@{$events}
	        or grep /^MODIFIED.$name$/,@{$events}
	    ) {
	        SolaxHybrid_APIAuth($hash);
	    }
	} 
	
	if ( $devtype eq 'SolaxHybrid') {
		if ( grep(/^state:.authenticated$/, @{$events}) ) {
        	SolaxHybrid_getMower($hash);
		}
		
		if ( grep(/^state:.connected$/, @{$events}) ) {
			SolaxHybrid_DoUpdate($hash);
		}
			
		if ( grep(/^state:.disconnected$/, @{$events}) ) {
		    Log3 $name, 3, "Reconnecting...";
			SolaxHybrid_APIAuth($hash);
		}
	}
            
    return undef;
}


sub SolaxHybrid_Attr(@) {
	
    my ( $cmd, $name, $attrName, $attrVal ) = @_;
    my $hash = $defs{$name};
		
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
    
	elsif( $attrName eq "username" ) {
		if( $cmd eq "set" ) {
		    $hash->{SolaxHybrid}->{username} = $attrVal;
		    Log3 $name, 5, "$name - username set to " . $hash->{SolaxHybrid}->{username};
		}
	}

	elsif( $attrName eq "password" ) {
		if( $cmd eq "set" ) {
			$hash->{SolaxHybrid}->{password} = $attrVal;
		    Log3 $name, 5, "$name - password set to " . $hash->{SolaxHybrid}->{password};	
		}
	}
	

	elsif( $attrName eq "interval" ) {
        if( $cmd eq "set" ) {
            RemoveInternalTimer($hash);
            return "Interval must be greater than 0"
            unless($attrVal > 0);
            $hash->{SolaxHybrid}->{interval} = $attrVal;
            Log3 $name, 5, "$name - set interval: $attrVal";
        }

        elsif( $cmd eq "del" ) {
            RemoveInternalTimer($hash);
            $hash->{SolaxHybrid}->{interval}   = 300;
            Log3 $name, 5, "$name - deleted interval and set to default: 300";
        }
    }

	
	
	
    return undef;
}


sub SolaxHybrid_Undef($$){
	my ( $hash, $arg )  = @_;
    my $name            = $hash->{NAME};
    my $deviceId        = $hash->{DEVICEID};
    delete $modules{SolaxHybrid}{defptr}{$deviceId};
    RemoveInternalTimer($hash);
    return undef;
}


sub SolaxHybrid_Set($@){
	my ($hash,@a) = @_;
    return "\"set $hash->{NAME}\" needs at least an argument" if ( @a < 2 );
    my ($name,$setName,$setVal,$setVal2,$setVal3) = @a;

	Log3 $name, 3, "$name: set called with $setName " . ($setVal ? $setVal : "") if ($setName ne "?");

	if (SolaxHybrid_CONNECTED($hash) eq 'disabled' && $setName !~ /clear/) {
        return "Unknown argument $setName, choose one of clear:all,readings";
        Log3 $name, 3, "$name: set called with $setName but device is disabled!" if ($setName ne "?");
        return undef;
    }

    if ($setName !~ /start|stop|park|update/) {
        return "Unknown argument $setName, choose one of start stop park update";
	}
	
	if ($setName eq 'update') {
        RemoveInternalTimer($hash);
        SolaxHybrid_DoUpdate($hash);
    }
    
	if (SolaxHybrid_CONNECTED($hash)) {

	    if ($setName eq 'start') {
		    SolaxHybrid_CMD($hash,'START');
		    
	    } elsif ($setName eq 'stop') {
		    SolaxHybrid_CMD($hash,'STOP');
		    
	    } elsif ($setName eq 'park') {
		    SolaxHybrid_CMD($hash,'PARK');
		    
	    }

	}
	
    return undef;

}


##############################################################
#
# API AUTHENTICATION
#
##############################################################

sub SolaxHybrid_APIAuth($) {
    my ($hash, $def) = @_;
    my $name = $hash->{NAME};
    
    my $username = $hash->{SolaxHybrid}->{username};
    my $password = $hash->{SolaxHybrid}->{password};
    
    my $header = "Content-Type: application/json\r\nAccept: application/json";
    

    HttpUtils_NonblockingGet({
        url        	=> SOLAXAPIURL . "/user/Login?username=" . uri_escape($username) . "&password=" . uri_escape($password),
        timeout    	=> 60,
        hash       	=> $hash,
        method     	=> "GET",
        header     	=> $header, 		
        callback   	=> \&SolaxHybrid_APIAuthResponse,
    });  
    
	SolaxHybrid_CONNECTED($hash,'OK');
	InternalTimer( time() + $hash->{SolaxHybrid}->{interval}, "SolaxHybrid_APIAuth", $hash, 0 );
}

sub SolaxHybrid_APIAuthResponse($) {
    my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

    if($err ne "") {
        Log3 $name, 3, "error while requesting ".$param->{url}." - $err";     
    } elsif($data ne "") {
	    
	    my $result = decode_json($data);
	    if ($result->{errors}) {
		 #   SolaxHybrid_CONNECTED($hash,'error');
		 Log3 $name, 3, "Error: " . $result->{errors}[0]->{detail};
		    
	    } else {
	        Log3 $name, 3, "$data"; 

			$hash->{SolaxHybrid}->{token} = $result->{data}{token};
			
			# set Readings	
			readingsBeginUpdate($hash);
			readingsBulkUpdate($hash,'token',$hash->{SolaxHybrid}->{token} );
			
			readingsEndUpdate($hash, 1);
	    }
    }

	SolaxHybrid_ReadBattery ( $hash );
	SolaxHybrid_ReadInverter ( $hash );
}


sub SolaxHybrid_ReadBattery($) {
    my ($hash, $def) = @_;
    my $name = $hash->{NAME};
    
	Log3 $name, 3, "ReadBattery invoked ..."; 
	
    my $header = "Content-Type: application/json\r\nAccept: application/json";
    my $token = $hash->{SolaxHybrid}->{token};
	
	Log3 $name, 3, $token; 
	
    HttpUtils_NonblockingGet({
        url        	=> SOLAXAPIURL . "/site/BatteryList/208117?date=2018-04-23&token=" . $token,
        timeout    	=> 60,
        hash       	=> $hash,
        method     	=> "GET",
        header     	=> $header, 		
        callback   	=> \&SolaxHybrid_ReadBatteryResponse,
    });  
    
}

sub SolaxHybrid_ReadBatteryResponse($) {
    my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

	$name = "SolaxHybrid";
	Log3 $name, 3, "ReadBatteryResponse invoked ... "; 
	Log3 $name, 3, $data; 
	
	
    if($err ne "") {
        Log3 $name, 3, "error while requesting ".$param->{url}." - $err";     
    } elsif($data ne "") {
	    
	    my $result = decode_json($data);
		
		Log3 $name, 3, $result->{successful} ;
		
	    if ($result->{successful} == 0) {
		 #   SolaxHybrid_CONNECTED($hash,'error');
		 Log3 $name, 3, "Error: " . $result->{data}->{errorMsg};
		    
	    } else {
	        Log3 $name, 3, "$data"; 

			$hash->{SolaxHybrid}->{battery_power} = $result->{data}[0]{batList}[0]{dataDict}[2]{value};
			$hash->{SolaxHybrid}->{battery_percent} = $result->{data}[0]{batList}[0]{dataDict}[4]{value};
			
			my $val = $result->{data}[0]{batList}[0]{dataDict}[4]{value};
			Log3 $name, 3, $val; 
			
			# set Readings	
			readingsBeginUpdate($hash);
			readingsBulkUpdate($hash,'battery_power',$hash->{SolaxHybrid}->{battery_power} );
			readingsBulkUpdate($hash,'battery_percent',$hash->{SolaxHybrid}->{battery_percent} );
			readingsEndUpdate($hash, 1);
	    }
        
    }
}




sub SolaxHybrid_ReadInverter($) {
    my ($hash, $def) = @_;
    my $name = $hash->{NAME};
    
	Log3 $name, 3, "ReadInverter invoked ..."; 
	
    my $header = "Content-Type: application/json\r\nAccept: application/json";
    my $token = $hash->{SolaxHybrid}->{token};
	
	Log3 $name, 3, $token; 
	
    HttpUtils_NonblockingGet({
        url        	=> SOLAXAPIURL . "/site/InverterList/208117?date=2018-04-23&token=" . $token,
        timeout    	=> 60,
        hash       	=> $hash,
        method     	=> "GET",
        header     	=> $header, 		
        callback   	=> \&SolaxHybrid_ReadInverterResponse,
    });  
    
}

sub SolaxHybrid_ReadInverterResponse($) {
    my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

	$name = "SolaxHybrid";
	Log3 $name, 3, "ReadInverterResponse invoked ... "; 
	Log3 $name, 3, $data; 
	
	
    if($err ne "") {
        Log3 $name, 3, "error while requesting ".$param->{url}." - $err";     
    } elsif($data ne "") {
	    
	    my $result = decode_json($data);
		
		Log3 $name, 3, $result->{successful} ;
		
	    if ($result->{successful} == 0) {
		 #   SolaxHybrid_CONNECTED($hash,'error');
		 Log3 $name, 3, "Error: " . $result->{data}->{errorMsg};
		    
	    } else {
	        Log3 $name, 3, "$data"; 

			my $inverter_id = $result->{data}[0]->{id};
			my $inverter_name = $result->{data}[0]->{name};
			my $inverter_sn = $result->{data}[0]->{sn};
			my $inverter_lastUpdateTime = $result->{data}[0]->{lastUpdateTime};
			my $inverter_data_powernow = fetchEntryFromDataDict("dqgl", \$result->{data}[0]->{dataDict});
			my $inverter_data_powerexported = fetchEntryFromDataDict("zyxsj", \$result->{data}[0]->{dataDict});
			my $inverter_data_powerinput1 = fetchEntryFromDataDict("pv1srgl", \$result->{data}[0]->{dataDict});
			my $inverter_data_powerinput2 = fetchEntryFromDataDict("pv2srgl", \$result->{data}[0]->{dataDict});
			my $inverter_data_powerinputTotal = $inverter_data_powerinput1 + $inverter_data_powerinput2;

			$hash->{SolaxHybrid}->{inverter_id} = $inverter_id;
			$hash->{SolaxHybrid}->{inverter_name} = $inverter_name;
			$hash->{SolaxHybrid}->{inverter_sn} = $inverter_sn;
			$hash->{SolaxHybrid}->{inverter_lastUpdateTime} = $inverter_lastUpdateTime;
			$hash->{SolaxHybrid}->{inverter_data_powernow} = $inverter_data_powernow;
			$hash->{SolaxHybrid}->{inverter_data_powerexported} = $inverter_data_powerexported;
			$hash->{SolaxHybrid}->{inverter_data_powerinputTotal} = $inverter_data_powerinputTotal;
			
			
			
			# set Readings	
			readingsBeginUpdate($hash);
			readingsBulkUpdate($hash,'inverter_id',$hash->{SolaxHybrid}->{inverter_id} );
			readingsBulkUpdate($hash,'inverter_name',$hash->{SolaxHybrid}->{inverter_name} );
			readingsBulkUpdate($hash,'inverter_sn',$hash->{SolaxHybrid}->{inverter_sn} );
			readingsBulkUpdate($hash,'inverter_lastUpdateTime',$hash->{SolaxHybrid}->{inverter_lastUpdateTime} );
			readingsBulkUpdate($hash,'inverter_data_powernow',$hash->{SolaxHybrid}->{inverter_data_powernow} );
			readingsBulkUpdate($hash,'inverter_data_powerexported',$hash->{SolaxHybrid}->{inverter_data_powerexported} );
			readingsBulkUpdate($hash,'inverter_data_powerinputTotal',$hash->{SolaxHybrid}->{inverter_data_powerinputTotal} );
			readingsEndUpdate($hash, 1);
			
			FW_directNotify("FILTER=room=SolaxHybrid", "#FHEMWEB:WEB", "location.reload('true')", "");
			FW_directNotify("FILTER=room=SolaxHybrid", "#FHEMWEB:WEB", "FW_okDialog('Hello world!')", "");
			 map { FW_directNotify("#FHEMWEB:$_", "location.reload()", "") } devspec2array("TYPE=FHEMWEB");
	    }
        
    }

}




sub fetchEntryFromDataDict($)
{
        my ($key, $array) = @_;
        my $result = undef;
        #print "$key Dump: " . Dumper @$$array[0]->{'value'} . "\n";

        foreach ( @$$array )
        {
                my $item = $_;
                if ( $item->{'key'} eq $key )
                {
                        #print $item->{'value'} . "\n";
                        $result=$item->{'value'};
                }
        }

        return $result;
}





sub SolaxHybrid_CONNECTED($@) {
	my ($hash,$set) = @_;
    if ($set) {
	  $hash->{SolaxHybrid}->{CONNECTED} = $set;
       RemoveInternalTimer($hash);
       %{$hash->{updateDispatch}} = ();
       if (!defined($hash->{READINGS}->{state}->{VAL}) || $hash->{READINGS}->{state}->{VAL} ne $set) {
       		readingsSingleUpdate($hash,"state",$set,1);
       }
	   return undef;
	} else {
		if ($hash->{SolaxHybrid}->{CONNECTED} eq 'disabled') {
            return 'disabled';
        }
        elsif ($hash->{SolaxHybrid}->{CONNECTED} eq 'connected') {
            return 1;
        } else {
            return 0;
        }
	}
}


##############################################################
#
# UPDATE FUNCTIONS
#
##############################################################

=head1
sub SolaxHybrid_DoUpdate($) {
    my ($hash) = @_;
    my ($name,$self) = ($hash->{NAME},SolaxHybrid_Whoami());

    Log3 $name, 3, "doUpdate() called.";

    if (SolaxHybrid_CONNECTED($hash) eq "disabled") {
        Log3 $name, 3, "$name - Device is disabled.";
        return undef;
    }

	if (time() >= $hash->{SolaxHybrid}->{expires} ) {
		Log3 $name, 3, "LOGIN TOKEN MISSING OR EXPIRED";
		SolaxHybrid_CONNECTED($hash,'disconnected');

	} elsif ($hash->{SolaxHybrid}->{CONNECTED} eq 'connected') {
		Log3 $name, 3, "Update with device: " . $hash->{SolaxHybrid}->{mower_id};
		SolaxHybrid_getMowerStatus($hash);
        InternalTimer( time() + $hash->{SolaxHybrid}->{interval}, $self, $hash, 0 );

	} 

}
=cut



##############################################################
#
# GET MOWERS
#
##############################################################

#sub SolaxHybrid_getMower($) {
#	my ($hash) = @_;
#   my ($name) = $hash->{NAME};
#
#	my $token = $hash->{SolaxHybrid}->{token};
#	my $provider = $hash->{SolaxHybrid}->{provider};
#	my $header = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: Bearer " . $token . "\r\nAuthorization-Provider: " . $provider;
#
#	HttpUtils_NonblockingGet({
 #       url        	=> APIURL . "mowers",
 #       timeout    	=> 5,
  #      hash       	=> $hash,
   #     method     	=> "GET",
    #    header     	=> $header,  
     #   callback   	=> \&SolaxHybrid_getMowerResponse,
   # });  
	
#	return undef;
#}

=head1
sub SolaxHybrid_getMowerResponse($) {
	
	my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

    if($err ne "") {
        Log3 $name, 5, "error while requesting ".$param->{url}." - $err";     
                                           
    } elsif($data ne "") {
	    
		if ($data eq "[]") {
		    Log3 $name, 3, "Please register an automower first";
		    $hash->{SolaxHybrid}->{mower_id} = "none";

		    # STATUS LOGGEDIN MUST BE REMOVED
			SolaxHybrid_CONNECTED($hash,'connected');

		} else {

		    Log3 $name, 5, "Automower(s) found"; 			
			Log3 $name, 5, $data; 
			
			my $result = decode_json($data);
			my $mower = $hash->{SolaxHybrid}->{mower};
			Log3 $name, 5, $result->[$mower]->{'name'};
		    
			# MOWER DATA
			my $mymower = $result->[$mower];
			$hash->{SolaxHybrid}->{mower_id} = $mymower->{'id'};
			$hash->{SolaxHybrid}->{mower_name} = $mymower->{'name'};
			$hash->{SolaxHybrid}->{mower_model} = $mymower->{'model'};

			# MOWER STATUS
		    my $mymowerStatus = $mymower->{'status'};
			$hash->{SolaxHybrid}->{mower_battery} = $mymowerStatus->{'batteryPercent'};
			$hash->{SolaxHybrid}->{mower_status} = $mymowerStatus->{'mowerStatus'};
			$hash->{SolaxHybrid}->{mower_mode} = $mymowerStatus->{'operatingMode'};
			
			$hash->{SolaxHybrid}->{mower_nextStart} = $mymowerStatus->{'nextStartTimestamp'};

			SolaxHybrid_CONNECTED($hash,'connected');

		}
		
		readingsBeginUpdate($hash);
		#readingsBulkUpdate($hash,$reading,$value);
		readingsBulkUpdate($hash, "mower_id", $hash->{SolaxHybrid}->{mower_id} );    
		readingsBulkUpdate($hash, "mower_name", $hash->{SolaxHybrid}->{mower_name} );    
		readingsBulkUpdate($hash, "mower_battery", $hash->{SolaxHybrid}->{mower_battery} );    
		readingsBulkUpdate($hash, "mower_status", $hash->{SolaxHybrid}->{mower_status} );    
		readingsBulkUpdate($hash, "mower_mode", $hash->{SolaxHybrid}->{mower_mode} );    
		
		my $nextStartTimestamp = strftime("%Y-%m-%d %H:%M:%S", gmtime($hash->{SolaxHybrid}->{mower_nextStart}));
		readingsBulkUpdate($hash, "mower_nextStart", $nextStartTimestamp );  
		  
		readingsEndUpdate($hash, 1);
 	    
	}	
	
	return undef;

}
=cut

=head1
sub SolaxHybrid_getMowerStatus($) {
	my ($hash) = @_;
    my ($name) = $hash->{NAME};

	my $token = $hash->{SolaxHybrid}->{token};
	my $provider = $hash->{SolaxHybrid}->{provider};
	my $header = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: Bearer " . $token . "\r\nAuthorization-Provider: " . $provider;

	my $mymower_id = $hash->{SolaxHybrid}->{mower_id};

	HttpUtils_NonblockingGet({
        url        	=> APIURL . "mowers/" . $mymower_id . "/status",
        timeout    	=> 5,
        hash       	=> $hash,
        method     	=> "GET",
        header     	=> $header,  
        callback   	=> \&SolaxHybrid_getMowerStatusResponse,
    });  
	
	return undef;
}
=cut

=head1
sub SolaxHybrid_getMowerStatusResponse($) {
	
	my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

    if($err ne "") {
        Log3 $name, 5, "error while requesting ".$param->{url}." - $err";     
                                           
    } elsif($data ne "") {
	    
		Log3 $name, 5, $data; 
		my $result = decode_json($data);

		Log3 $name, 3, $hash->{SolaxHybrid}->{mower_nextStart};
		
		$hash->{SolaxHybrid}->{mower_battery} = $result->{'batteryPercent'};
		$hash->{SolaxHybrid}->{mower_status} = $result->{'mowerStatus'};
		$hash->{SolaxHybrid}->{mower_mode} = $result->{'operatingMode'};
		$hash->{SolaxHybrid}->{mower_nextStart} = $result->{'nextStartTimestamp'};
		$hash->{SolaxHybrid}->{mower_lastLatitude} = $result->{'lastLocations'}->[0]->{'latitude'};
		$hash->{SolaxHybrid}->{mower_lastLongitude} = $result->{'lastLocations'}->[0]->{'longitude'};


		
		readingsBeginUpdate($hash);
		#readingsBulkUpdate($hash,$reading,$value);
		readingsBulkUpdate($hash, "mower_battery", $hash->{SolaxHybrid}->{mower_battery} );    
		readingsBulkUpdate($hash, "mower_status", $hash->{SolaxHybrid}->{mower_status} );    
		readingsBulkUpdate($hash, "mower_mode", $hash->{SolaxHybrid}->{mower_mode} );  
		
		my $nextStartTimestamp = strftime("%Y-%m-%d %H:%M:%S", gmtime($hash->{SolaxHybrid}->{mower_nextStart}));
		readingsBulkUpdate($hash, "mower_nextStart", $nextStartTimestamp );  
  
		readingsBulkUpdate($hash, "mower_lastLatitude", $hash->{SolaxHybrid}->{mower_lastLatitude} );    
		readingsBulkUpdate($hash, "mower_lastLongitude", $hash->{SolaxHybrid}->{mower_lastLongitude} );    
		readingsEndUpdate($hash, 1);
	    
	}	
	
	return undef;

}


##############################################################
#
# SEND COMMAND
#
##############################################################

sub SolaxHybrid_CMD($$) {
    #my ($hash, $def) = @_;
    my ($hash,$cmd) = @_;
    my $name = $hash->{NAME};
    
    # valid commands ['PARK', 'STOP', 'START']
    my $token = $hash->{SolaxHybrid}->{token};
	my $provider = $hash->{SolaxHybrid}->{provider};
    my $mower_id = $hash->{SolaxHybrid}->{mower_id};

	my $header = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: Bearer " . $token . "\r\nAuthorization-Provider: " . $provider;
    
    Log3 $name, 3, "cmd: " . $cmd;     
    my $json = '{"action": ' . $cmd . '}';

    HttpUtils_NonblockingGet({
        url        	=> APIURL . "mowers/". $mower_id . "/control",
        timeout    	=> 5,
        hash       	=> $hash,
        method     	=> "POST",
        header     	=> $header,
		data 		=> $json,
        callback   	=> \&SolaxHybrid_CMDResponse,
    });  
    
}
=cut

=head1
sub SolaxHybrid_CMDResponse($) {
    my ($param, $err, $data) = @_;
    my $hash = $param->{hash};
    my $name = $hash->{NAME};

    if($err ne "") {
	    SolaxHybrid_CONNECTED($hash,'error');
        Log3 $name, 3, "error while requesting ".$param->{url}." - $err";     
                                           
    } elsif($data ne "") {
	    
	    my $result = decode_json($data);
	    if ($result->{errors}) {
		    SolaxHybrid_CONNECTED($hash,'error');
		    Log3 $name, 3, "Error: " . $result->{errors}[0]->{detail};
		    
	    } else {
	        Log3 $name, 3, "$data"; 

			
	    }
        
    }

}
=cut

###############################################################################

sub SolaxHybrid_Whoami()  { return (split('::',(caller(1))[3]))[1] || ''; }
sub SolaxHybrid_Whowasi() { return (split('::',(caller(2))[3]))[1] || ''; }

##############################################################

1;

=pod

=item device
=item summary    Modul to control Husqvarna Automower with Connect Module (SIM)
=item summary_DE Modul zur Steuerung von Husqvarna Automower mit Connect Modul (SIM)

=begin html

<a name="SolaxHybrid"></a>
<h3>Husqvarna Automower with Connect Module (SIM)</h3>
<ul>
	<u><b>Requirements</b></u>
  	<br><br>
	<ul>
		<li>This module allows the communication between the Husqvarna Cloud and FHEM.</li>
		<li>You can control any Automower that is equipped with the original Husqvarna Connect Module (SIM).</li>
  		<li>The Automower must be registered in the Husqvarna App beforehand.</li>
  	</ul>
	<br>
	
	<a name="SolaxHybriddefine"></a>
	<b>Define</b>
	<ul>
		<code>define &lt;name&gt; SolaxHybrid</code>
		<br><br>
		Beispiel:
		<ul><br>
			<code>define myMower SolaxHybrid<br>
			attr myMower username YOUR_USERNAME<br>
			attr myMower password YOUR_PASSWORD
			</code><br>
		</ul>
		<br><br>
		You must set both attributes <b>username</b> and <b>password</b>. These are the same that you use to login via the Husqvarna app.
	</ul>
	<br>
	
	<a name="SolaxHybridattributes"></a>
	<b>Attributes</b>
	<ul>
		<li>username - Email that is used in Husqvarna App</li>
		<li>password - Password that is used in Husqvarna App</li>
		<li>mower - (optional) Automower, if more that one is registered (e. g. 1)</li>
	</ul>
	<br>

	<a name="SolaxHybridreadings"></a>
	<b>Readings</b>
	<ul>
		<li>expires - date when session of Husqvarna Cloud expires</li>
		<li>mower_id - ID of the mower</li>
		<li>mower_lastLatitude - last known position (latitude)</li>
		<li>mower_lastLongitude - last known position (longitude)</li>
		<li>mower_mode - current working mode (e. g. AUTO)</li>
		<li>mower_name - name of the mower</li>
		<li>mower_nextStart - next start time</li>
		<li>mower_status - current status (e. g. OFF_HATCH_CLOSED_DISABLED)</li>
		<li>provider - should be Husqvarna</li>
		<li>state - status of connection to Husqvarna Cloud (e. g. connected)</li>
		<li>token - current session token of Husqvarna Cloud</li>
		<li>user_id - your user ID in Husqvarna Cloud</li>
	</ul>

</ul>

=end html



=begin html_DE

<a name="SolaxHybrid"></a>
<h3>Husqvarna Automower mit Connect Modul</h3>
<ul>
	<u><b>Voraussetzungen</b></u>
	<br><br>
	<ul>
		<li>Dieses Modul ermöglicht die Kommunikation zwischen der Husqvarna Cloud und FHEM.</li>
		<li>Es kann damit jeder Automower, der über ein original Husqvarna Connect Modul (SIM) verfügt, überwacht und gesteuert werden.</li>
		<li>Der Automower muss vorab in der Husqvarna App eingerichtet sein.</li>
	</ul>
	<br>
	
	<a name="SolaxHybriddefine"></a>
	<b>Define</b>
	<ul>
		<br>
		<code>define &lt;name&gt; SolaxHybrid</code>
		<br><br>
		Beispiel:
		<ul><br>
			<code>define myMower SolaxHybrid<br>
			attr myMower username YOUR_USERNAME<br>
			attr myMower password YOUR_PASSWORD
			</code><br>
		</ul>
		<br><br>
		Es müssen die beiden Attribute <b>username</b> und <b>password</b> gesetzt werden. Diese sind identisch mit den Logindaten der Husqvarna App.
	</ul>
	<br>
	
	<a name="SolaxHybridattributes"></a>
	<b>Attributes</b>
	<ul>
		<li>username - Email, die in der Husqvarna App verwendet wird</li>
		<li>password - Passwort, das in der Husqvarna App verwendet wird</li>
		<li>mower - (optional) Automower, sofern mehrere registriert sind (z. B. 1)</li>
	</ul>
	<br>
	
	<a name="SolaxHybridreadings"></a>
	<b>Readings</b>
	<ul>
		<li>expires - Datum wann die Session der Husqvarna Cloud abläuft</li>
		<li>mower_id - ID des Automowers</li>
		<li>mower_lastLatitude - letzte bekannte Position (Breitengrad)</li>
		<li>mower_lastLongitude - letzte bekannte Position (Längengrad)</li>
		<li>mower_mode - aktueller Arbeitsmodus (e. g. AUTO)</li>
		<li>mower_name - Name des Automowers</li>
		<li>mower_nextStart - nächste Startzeit</li>
		<li>mower_status - aktueller Status (e. g. OFF_HATCH_CLOSED_DISABLED)</li>
		<li>provider - Sollte immer Husqvarna sein</li>
		<li>state - Status der Verbindung zur Husqvarna Cloud (e. g. connected)</li>
		<li>token - aktueller Sitzungstoken für die Husqvarna Cloud</li>
		<li>user_id - Nutzer-ID in der Husqvarna Cloud</li>
	</ul>

</ul>


=end html_DE
