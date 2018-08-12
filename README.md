# solax
Small tools to access data provided by a Solax 3700 - either directly or by querying the cloud storage.

## 74_SolaxDirect.pm
This module can be used to retrieve data from a Solax 3700 (or compatible) directly without using the cloud servers. For this to work it is mandatory that the inverted is reachable from the local network. The solax' default (WLAN) IP is 11.11.11.1. You can test your connection using a common browser and this IP:
```
http://11.11.11.1//api/realTimeData.htm
```
You should get back some sort of data, like this:
```
{"method":"uploadsn","version":"Solax_SI_CH_2nd_20190910_DE01","type":"AL_SE","SN":"4711111","Data":[3.3,7.3,212.2,202.0,5.2,228.5,1161,38,2.8,1475.6,-28,700,1474,54.65,16.45,900,27,75,0.0,348.8,,,,,,,,,,,,,,,,,,,,,,1143.20,100.90,,,,,,,,50.00,,,0.0,0.0,0,0.00,0,0,0,0.00,0,8,0,0,0.00,0,8],"Status":"2"}
```

If this works for you you can use the 74_SolaxDirect.pm FHEM module to connect to your inverted.

### Installation of the module
Installation as pretty simple:
Locate your FHEM installation folder. There you will find a subfolder called "FHEM". In this folder you will find all your fhem modules. 
Simply copy 74_SolaxDirect.pm into this folder.
After that you need to restart your fhem intallation with "shutdown restart".

In the unlikely case that your fhem installation does not start again, simply delete the module from the folder.

### Configuration of the module
After the module was intalled you can define an instance of your module:
```
defmod solax SolaxDirect 11.11.11.1 80
```
This defines a instance with name "solax". The IP of the inverted is 11.11.11.1 the port is 80.
After that you should have a new room "SolaxDirec" with this instance in it.

#### Attributes
The module has three attributes:
- host ... the hostname or IP address. It's mandatory parameter while creating the instance.
- port ... the port to connect to Default is 80.
- interval ... the interval in which the module should fetch data from the inverted. Defaults to 60 seconds. I'd not recommend to go below that! Optional.

### Troubleshooting 
- In case your module cannot be instanciated validate the log to have all needed perl modules installed. It might be that you're missing the "Json" perl module.
- in case the module is not able to fetch data from your inverted, check IP and/or port.
- if you module get's stuck - check the inverter ... the web interface sees to be not that stable!


