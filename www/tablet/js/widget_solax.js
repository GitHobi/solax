var Modul_solax = function () {

    function init() {
        
	
		me.elements = $('div[data-type="' + me.widgetname + '"]:not([data-ready])', me.area);
        me.elements.each(function (index) {
		 
			var elem = $(this);
			elem.initData('get', 'STATE');
			me.addReading(elem, 'get');
			
			var prefix = Math.floor(Math.random()*100000)+"a"+Math.floor(Math.random()*100000);
			elem.data('prefix', prefix);
	
			
			var html = `
<style>			
	.innerText2 {
    position: absolute;
    width: 100%;
    top: 84px;
    font-size: 12px;
    text-align: center;
    color: #D09421;
    font-family: arial;
}

.innerText {
    position: absolute;
    width: 100%;
    top: 66px;
    font-size: 12px;
    text-align: center;
    color: #D09421;
    font-family: arial;
}

.red {
    color: #FF9421;
}

.green {
    color: #D0F021;
}
</style>			
			
			<div id="${prefix}lastUpdate" style="font-size:8px">${prefix}</div>
			
	<div id="${prefix}SolaXWidget" style="transform-origin: top left;transform: scale(0.81,0.81);background-color:transparent;position:relative;width:400px;height:350px;">
			<div style="position:absolute;top:145px;left:150px; background:url(/fhem/Solax/home-load-power.png) no-repeat;background-size:100%;width:100px;height:140px;">
				<div id="${prefix}homePower" class="innerText">100W</div>
			</div>
			<div style="position:absolute;top:10px;left:150px; background:url(/fhem/Solax/home-pv.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="${prefix}solarPower" class="innerText2">200W</div>
	</div>
	
	<div id="${prefix}batteryImage" style="position:absolute;top:195px;left:273px; background:url(/fhem/Solax/home-battery-power4.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="${prefix}batteryPower" class="innerText $batteryLoading">300W</div>
		<div id="${prefix}batteryPercent" class="innerText $batteryLoading" style="top:77px;font-size:10px;">100%</div>
	</div>
	
	<div id="${prefix}batteryCharging" style="position:absolute;top:195px;left:273px; background:url(/fhem/Solax/home-battery-power-discharging.png) no-repeat;background-size:100%;width:100px;height:140px;">
	</div>

	<div style="position:absolute;top:195px;left:25px; background:url(/fhem/Solax/home-grid.png) no-repeat;background-size:100%;width:100px;height:140px;">
		<div id="${prefix}exportedPower" class="innerText $powerExporting">400W</div>
	</div>
	<div id="${prefix}GridCharging" style="position:absolute;top:195px;left:25px; background:url(/fhem/Solax/home-battery-power-discharging.png) no-repeat;background-size:100%;width:100px;height:140px;">
	</div>
	
	<div id="${prefix}imgPV2Home" style="position:absolute;top:118px;left:195px; background:url(/fhem/Solax/s2-0.gif) no-repeat;background-size:100%;width:10px;height:60px;"></div>
	<div id="${prefix}imgBattery2Home" style="position:absolute;top:200px;left:250px; background:url(/fhem/Solax/s5-0.gif) no-repeat;background-size:100%;width:27px;height:60px;"></div>
	<div id="${prefix}imgGrid2Home" style="position:absolute;top:200px;left:120px; background:url(/fhem/Solax/s4-0.gif) no-repeat;background-size:100%;width:27px;height:60px;"></div>


	<div id="${prefix}imgPV2Battery" style="position:absolute;top:70px;left:255px; background:url(/fhem/Solax/s3-0.gif) no-repeat;background-size:100%;width:80px;height:200px;"></div>
	<div style="position:absolute;top:285px;left:110px; background:url(/fhem/Solax/s6-0.gif) no-repeat;background-size:100%;width:180px;height:60px;"></div>
	<div id="${prefix}imgPV2Grid" style="position:absolute;top:70px;left:65px; background:url(/fhem/Solax/s1-0.gif) no-repeat;background-size:100%;width:80px;height:200px;"></div>
	
	`;
			var elemImg = $(html).appendTo(elem);
			
		});
    }
	
	function init_ui(elem) {
        
		console.log ( "-------------- Update  -------------------");
		
	
		var tid = setInterval(function () {
            if (elem) {

                
                var text = "hallo";
                elem.text(text);

            } 
        }, 1000);
	
    }

	
		
	
    function update(dev, par) {
		
        me.elements.filterDeviceReading('get', dev, par)
            .each(function (index) {
                var elem = $(this);
                var value = elem.getReading('get').val;
                //console.log('readingsgroup:',value);
                if (ftui.isValid(value)) {
                    var dNow = new Date();

                    var lUpdate = elem.data('lastUpdate') || null;
                    var lMaxUpdate = parseInt(elem.data('max-update'));
                    if (isNaN(lMaxUpdate) || (lMaxUpdate < 1))
                        lMaxUpdate = 10;

                    //console.log('readingsgroup update time stamp diff : ', dNow - lUpdate, '   param maxUPdate :' + lMaxUpdate + '    : ' + $(this).data('max-update') );
                    lUpdate = (((dNow - lUpdate) / 1000) > lMaxUpdate) ? null : lUpdate;
                    if (lUpdate === null) {
                        //console.log('readingsgroup DO update' );
                        elem.data('lastUpdate', dNow);

                        var cmd = [ 'get', elem.data('device'), "json" ].join(' ');
                        ftui.log('readingsgroup update', dev, ' - ', cmd);
                        //console.log ( "cmd: " + cmd);
                        ftui.sendFhemCommand(cmd)
                            .done(function (data, dev) {
                            //console.log('cmd: received update : ', data );
							
                            var obj = JSON.parse(data);
							
							var prefix = elem.data('prefix');
							//console.log (prefix);
							
							document.getElementById(prefix + "homePower").innerText = obj.powerHouse + "W";
							document.getElementById(prefix + "solarPower").innerText = obj.powerSolar + "W";
							document.getElementById(prefix + "exportedPower").innerText = obj.powerExported + "W";
							document.getElementById(prefix + "batteryPower").innerText = obj.batteryPower + "W";
							document.getElementById(prefix + "batteryPercent").innerText = obj.batteryPercent + "%";
							
							document.getElementById(prefix + "imgPV2Home").style.backgroundImage= obj.powerSolar > 0 ? "url(/fhem/Solax/s2-1.gif)" : "url(/fhem/Solax/s2-0.gif)";
							document.getElementById(prefix + "imgBattery2Home").style.backgroundImage= obj.powerSolar > 0 ? "url(/fhem/Solax/s5-2.gif)" : "url(/fhem/Solax/s5-0.gif)";
							document.getElementById(prefix + "imgGrid2Home").style.backgroundImage= obj.powerExported > 0 ? "url(/fhem/Solax/s4-0.gif)" : "url(/fhem/Solax/s4-2.gif)";
							
							document.getElementById(prefix + "imgPV2Battery").style.backgroundImage= obj.batteryPower > 0 ? "url(/fhem/Solax/s3-1.gif)" : "url(/fhem/Solax/s3-0.gif)";
							document.getElementById(prefix + "imgPV2Grid").style.backgroundImage= obj.powerExported > 0 ? "url(/fhem/Solax/s1-1.gif)" : "url(/fhem/Solax/s1-0.gif)";
							
							
							var batteryImage = "url(/fhem/Solax/home-battery-power4.png)"
							if ( obj.batteryPercent < 85 ) {
								batteryImage = "url(/fhem/Solax/home-battery-power3.png)"
							}
							if ( obj.batteryPercent < 60 ) {
								batteryImage = "url(/fhem/Solax/home-battery-power2.png)"
							}
							if ( obj.batteryPercent < 30 ) {
								batteryImage = "url(/fhem/Solax/home-battery-power1.png)"
							}
							if ( obj.batteryPercent < 20 ) {
								batteryImage = "url(/fhem/Solax/home-battery-power0.png)"
							}
							document.getElementById(prefix + "batteryImage").style.backgroundImage = batteryImage;

							
							batteryImage = "";
							if ( obj.batteryPower > 20 ) {
									batteryImage = "url(/fhem/Solax/home-battery-power-charging.png)";
							}
							if ( obj.batteryPower < -20 ) {
									batteryImage = "url(/fhem/Solax/home-battery-power-discharging.png)";
							}
							document.getElementById(prefix + "batteryCharging").style.backgroundImage = batteryImage;

							
							batteryImage = "";
							if ( obj.powerExported > 20 ) {
									batteryImage = "url(/fhem/Solax/home-battery-power-charging.png)";
									
							}
							if ( obj.powerExported < -20 ) {
									batteryImage = "url(/fhem/Solax/home-battery-power-discharging.png)";
							}
							document.getElementById(prefix + "GridCharging").style.backgroundImage = batteryImage;
							
							
							document.getElementById(prefix + 'lastUpdate').innerText = dNow.getHours() + ":" + dNow.getMinutes() + ":" + dNow.getSeconds();
							
							
							
							
                        });
                    }
                }
            });
		
    }

    var me = $.extend(new Modul_widget(), {
        widgetname: 'solax',
        init: init,
		init_ui: init_ui,
        update: update,
    });

    return me;
};