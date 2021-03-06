// load highcharts libs
function depends_highchart()
{
	if (!$.fn.highchart)
	{
		return [ftui.config.basedir + 'lib/highcharts/highcharts.js', ftui.config.basedir + 'lib/highcharts/highcharts-more.js', ftui.config.basedir + 'lib/highcharts/themes/dark-blue.js'
		];
	}
}

var Modul_highchart = function ()
{

	function init_attr(elem)
	{
		//elem.initData('minvalue', 10);
		//elem.initData('maxvalue', 30);
		//elem.initData('xticks', 360);
		//elem.initData('yticks', 5);
		elem.initData('yunit', '');
		elem.initData('get', 'STATE');

		this.addReading(elem, 'get');
	}

	function init_ui(elem)  {}

	function precision(a)
	{
		var s = a + '';
		var d = s.indexOf('.') + 1;
		return !d ? 0 : s.length - d;
	}

	function refresh(elem)
	{

		var minarray = [0];
		var maxarray = [0];
		if (elem.data('minvalue'))
		{
			minarray = ("" + elem.data('minvalue')).split(',');
		}
		
		if (elem.data('maxvalue'))
		{
			maxarray = ("" + elem.data('maxvalue')).split(',');
		}

		var min = parseFloat($.isArray(minarray) ? minarray[0] : minarray);
		var max = parseFloat($.isArray(maxarray) ? maxarray[0] : maxarray);

		var tickInterval = parseFloat(elem.data('tickinterval')) || null;
		var tickAmount = parseFloat(elem.data('tickamount')) || null;
		var fix = precision($(this).data('yticks'));
		var xunit = elem.data('xunit');
		var yunit = elem.data('yunit');
		var title = elem.data('title');
		var subtitle = elem.data('subtitle');
		var tooltip = elem.data('tooltip');
		var legendEnabled = !(elem.data('legend') === 0);
		var noticks = (elem.data('width') <= 100) ? true : elem.hasClass('noticks');
		var days = parseFloat(elem.data('daysago') || 0);
		var height = parseInt(elem.data('height')) || 250;
		var width = parseInt(elem.data('width')) || 350;
		var now = new Date();
		var ago = new Date();
		var mindate = now;
		var maxdate = now;
		var lineNames = [];
		var lineTypes = [];
		var uaxis = [];
		var unitspec = [];
		var axisopposite = [];
		var axislabel = [];
		var yTickInterval = [];

		if (days > 0 && days < 1)
		{
			ago.setTime(now.getTime() - (days * 24 * 60 * 60 * 1000));
			mindate = ago.yyyymmdd() + '_' + ago.hhmmss();
		}
		else
		{
			ago.setDate(now.getDate() - days);
			mindate = ago.yyyymmdd() + '_00:00:00';
		}

		maxdate.setDate(now.getDate() + 1);
		maxdate = maxdate.yyyymmdd() + '_00:00:00';
		
		if (elem.data('yTickInterval'))
		{
			yTickInterval = elem.data('yTickInterval').split(',');
		}
		
		if (elem.data('axislabel'))
		{
			axislabel = elem.data('axislabel').split(',');
		}
		
		if (elem.data('axisopposite'))
		{
			axisopposite = elem.data('axisopposite').split(',');
		}
		
		if (elem.data('uaxis'))
		{
			uaxis = elem.data('uaxis').split(',');
		}

		if (elem.data('linetypes'))
		{
			lineTypes = elem.data('linetypes').split(',');
		}

		if (elem.data('linenames'))
		{
			lineNames = elem.data('linenames').split(',');
		}

		if (elem.data('unitspec'))
		{
			unitspec = elem.data('unitspec').split(',');
		}

		var pointFormat = {};
		if (tooltip)
		{
			pointFormat =
			{
				pointFormat: tooltip
			};
		}

		var column_spec;
		if (elem.data('columnspec'))
		{
			column_spec = elem.data('columnspec');
		}
		else
		{
			var device = elem.data('device') || '';
			var reading = elem.data('get') || '';
			column_spec = device + ':' + reading;
		}

		if (!column_spec.match(/.+:.+/))
		{
			console.log('columnspec ' + column_spec + ' is not ok in highchart' + (elem.data('device') ? ' for device ' + elem.data('device') : ''));
		}

		var logdevice = elem.data('logdevice');
		var logfile = elem.data('logfile') || '-';

		var cmd = ['get', logdevice, logfile, '-', mindate, maxdate, column_spec].join(' ');
		ftui.sendFhemCommand(cmd)
		.done(function (data)
		{
			//console.log ( "cmd: " + cmd);

			var seriesCount = 0;
			var seriesData = [];
			var axisData = [];
			var lineData = [];
			var lines = data.split('\n');
			var point = [];
			var firstTime = ftui.dateFromString(mindate);
			var dataCount = 0;
		
			if (minarray.length >0 )
			{
				for (var i = 0; i < minarray.length; i++)
				{
					var dataName = "";
					var unitSymbol = $.isArray(unitspec) ? unitspec[i] : unitspec;
					if (axislabel[i])
					{
						dataName = axislabel[i];
					}

					var tmpAxisData =
					{
						alignTicks : true,
						myUnit : unitspec[i],
						title:
						{
							text: dataName,
							style:
							{
								color: Highcharts.getOptions().colors[i]
							}
						},
						//tickAmount: tickAmount,
						tickInterval: yTickInterval[i],
						labels:
						{
							formatter: function ()
							{
								return this.value + this.axis.userOptions.myUnit;
							},
							style:
							{
								color: Highcharts.getOptions().colors[i]
							}
						},
						
						opposite: axisopposite[i]==1
					};

					
					if ( minarray[i] != maxarray[i] )
					{
						tmpAxisData.min = minarray[i];
						tmpAxisData.max = maxarray[i];
					}
					
					axisData[i] = tmpAxisData;
				}
			}
			
		
			
			var oldvalue = -4711;
			$.each(lines, function (index, value)
			{
				if (value)
				{
					var val = parseFloat(ftui.getPart(value.replace('\r\n', ''), 2));
					
					if ( oldvalue == -4711)
					{
						oldvalue = val
					}
					
					if ( Math.abs(oldvalue - val) > 500 && val == 0.00)
					{
						return true;
					}
					
					oldvalue = val;
					
					
					var eventTime = ftui.dateFromString(value).getTime();
					if (eventTime && $.isNumeric(val))
					{
						point = [eventTime * 1, val * 1];
						lineData[dataCount++] = point;
					}
					else
					{
						var dataName = val;
						if (lineNames[seriesCount])
						{
							dataName = lineNames[seriesCount];
						}
						var lineType = 'area';
						if (lineTypes[seriesCount])
						{
							lineType = lineTypes[seriesCount];
						}

						var unitSymbol = $.isArray(unitspec) ? unitspec[seriesCount] : unitspec;
						var targetAxis = uaxis.length > 1 ? Math.abs(uaxis[seriesCount]) : 0;

						
						var myLineWidth = 1;
						if ( "area" != lineType ) 
						{
							myLineWidth = 2;
						}
						
						seriesData[seriesCount] =
						{
							type: lineType,
							name: dataName,
							data: lineData,
							animation: true,
							
							fillColor: {
								linearGradient: [0, 0, 0, 400],
								stops: [
									[0, Highcharts.getOptions().colors[seriesCount]],
									[1, Highcharts.Color(Highcharts.getOptions().colors[seriesCount]).setOpacity(0).get('rgba')]
								]
							},
							lineWidth: myLineWidth
						};

						seriesData[seriesCount].yAxis = targetAxis;;

						seriesCount++;

						
						dataCount = 0;
						lineData = [];
					}
				}
			}
			);

			var xrange = parseInt(ftui.diffMinutes(firstTime, ftui.dateFromString(maxdate)));

			// highchart expects UTC per default (issue #136)
			Highcharts.setOptions(
			{
				global:
				{
					useUTC: false
				}
			}
			);

			
			elem.highcharts(
			{
				chart:
				{
					zoomType: 'x',
					backgroundColor: 'transparent',
					width: width,
					height: height
				},
				title:
				{
					text: title
				},
				subtitle:
				{
					text: subtitle
				},
				xAxis:
				{
					title:
					{
						text: xunit
					},
					tickInterval: tickInterval,
					type: 'datetime'
				},
				
				yAxis: axisData,
				tooltip: pointFormat,
				plotOptions:
				{
					area:
					{
						marker:
						{
							enabled: false,
							symbol: 'circle',
							radius: 2,
							states:
							{
								hover:
								{
									enabled: true
								}
							}
						}
					}
				},
				legend:
				{
					enabled: legendEnabled
				},
				credits:
				{
					text: '',
					href: '#'
				},
				series: seriesData
			}
			);
		}
		);
	}

	function update(dev, par)
	{
		me = this;
		me.elements.filterDeviceReading('get', dev, par)
		.each(function (index)
		{
			refresh($(this));
		}
		);
	}

	// public
	// inherit all public members from base clas
	var me = this;
	return $.extend(new Modul_widget(),
	{
		widgetname: 'highchart',
		init_attr: init_attr,
		init_ui: init_ui,
		update: update,
		precision: precision,
		refresh: refresh
	}
	);
};
