# solax
Interface to talk to solax hybrid inverter

## Sign on:
The first call needs to be to "Login" to get a token.
```
curl "http://www.solax-portal.com/api/v1/user/Login?username=USERNAME&password=PASSWORD"
{
    "data": {
        "id": 21928,
        "token": "dd754cf8dfb14b3a9249f85fe59eeb6a"
    },
    "successful": true,
    "message": null
}
```

The "token" is in subsequent calls needed to authenticate.

## Retrieve site information:

```
curl "http://www.solax-portal.com/api/v1/user/SiteList?token=dd754cf8dfb14b3a9249f85fe59eeb6a"

{
    "data": [{
        "id": 108111,
        "name": "blablabla",
        "type": "AL_SE",
        "energyToday": 3.0250,
        "power": 1211,
        "lastUpdateTime": "2018/4/23 12:39:50",
        "timezone": 1.00,
        "addTime": "2018-04-21"
    }],
    "successful": true,
    "message": null
}
```

## read data from inverter

```
curl "http://www.solax-portal.com/api/v1/site/InverterList/108111?date=2018-04-23&token=dd754cf8dfb14b3a9249f85fe59eeb6a"
{
    "data": [{
        "id": 111585,
        "name": "Inverter",
        "sn": "111919D4",
        "dataDict": [{
            "key": "pv1dl",
            "name": "PV1 Current",
            "value": 2.5,
            "unit": "A"
        }, {
            "key": "pv2dl",
            "name": "PV2 Current",
            "value": 2.8,
            "unit": "A"
        }, {
            "key": "pv1dy",
            "name": "PV1 Voltage",
            "value": 205.1,
            "unit": "V"
        }, {
            "key": "pv2dy",
            "name": "PV2 Voltage",
            "value": 204.1,
            "unit": "V"
        }, {
            "key": "nbdl",
            "name": "Output Current",
            "value": 4.6,
            "unit": "A"
        }, {
            "key": "dwdy",
            "name": "Network Voltage",
            "value": 229.8,
            "unit": "V"
        }, {
            "key": "dqgl",
            "name": "Power Now",
            "value": 1033,
            "unit": "W"
        }, {
            "key": "zyxsj",
            "name": "Exported Power",
            "value": 851,
            "unit": "W"
        }, {
            "key": "pv1srgl",
            "name": "PV1 Input Power",
            "value": 512,
            "unit": "W"
        }, {
            "key": "pv2srgl",
            "name": "PV2 Input Power",
            "value": 571,
            "unit": "W"
        }, {
            "key": "togrid",
            "name": "Exported energy",
            "value": 12.90,
            "unit": "kWh"
        }, {
            "key": "fromgrid",
            "name": "Grid Consumption",
            "value": 3.50,
            "unit": "kWh"
        }, {
            "key": "fac1",
            "name": "FAC1",
            "value": 49.98,
            "unit": "HZ"
        }, {
            "key": "dtfdl",
            "name": "Today\u0027s Energy",
            "value": 3.8,
            "unit": "kWh"
        }, {
            "key": "zfdl",
            "name": "Total Energy",
            "value": 26.1,
            "unit": "kWh"
        }, {
            "key": "epsv",
            "name": "EPS Voltage",
            "value": 0.0,
            "unit": "V"
        }, {
            "key": "epsc",
            "name": "EPS Current",
            "value": 0.0,
            "unit": "A"
        }, {
            "key": "epsp",
            "name": "EPS Power",
            "value": 0,
            "unit": "W"
        }, {
            "key": "epsf",
            "name": "EPS Frequency",
            "value": 0.00,
            "unit": "Hz"
        }, {
            "key": "bmslost",
            "name": "BMS Lost",
            "value": 0,
            "unit": ""
        }],
        "lastUpdateTime": "2018/4/23 12:34:48",
        "type": "AL_SE"
    }],
    "successful": true,
    "message": null
}
```

## read data from battery

```
curl "http://www.solax-portal.com/api/v1/site/BatteryList/108111?date=2018-04-23&token=dd754cf8dfb14b3a9249f85fe59eeb6a"

{
    "data": [{
        "id": 111585,
        "name": "Inverter",
        "batList": [{
            "name": "Battery1",
            "dataDict": [{
                "key": "b1_1",
                "name": "Battery V.",
                "value": 57.63,
                "unit": "V"
            }, {
                "key": "b1_2",
                "name": "Battery I.",
                "value": -0.10,
                "unit": "A"
            }, {
                "key": "b1_3",
                "name": "Battery P.",
                "value": -6,
                "unit": "W"
            }, {
                "key": "b1_4",
                "name": "Inner T.",
                "value": 25,
                "unit": "℃"
            }, {
                "key": "b1_5",
                "name": "Remaining Capacity % ",
                "value": 100,
                "unit": "%"
            }]
        }]
    }],
    "successful": true,
    "message": null
}
```

## access to mobile site

http://www.solax-portal.com/m/home/loginpost

## get balance

```
curl "http://www.solax-portal.com/api/v1/site/EnergyTypeColumn/208117?date=2018-05-17&timeType=0&reportType=2&lang=en&token=dd754cf8dfb14b3a9249f85fe59eeb6a"

{
    "data": [{
        "name": "Exported energy",
        "data": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1, 0, 0, null, null, null, null]
    }, {
        "name": "Grid Consumption",
        "data": [0.1, 0, 0.1, 0, 0.1, 0.1, 0.1, 0.1, 0.1, 0, 0.1, 0, 0, 0.1, 0, 0, 0.1, 0, 0.1, 0.3, null, null, null, null]
    }],
    "stacking": "",
    "timeType": 0,
    "startTime": "\/Date(1526486400000)\/",
    "categories": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"],
    "times": ["2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17", "2018-05-17"]
}
```

### ReportType

Value | Type
------------ | -------------
0 | Yield
1 | Consumption
2 | Balance

