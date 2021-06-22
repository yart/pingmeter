# PingMeter

A simple tool for making measurements of pings of IP-addresses. You can use it at http://pingmeter.online or you can
install the app on your desktop or laptop.

## How to install

```bash
$ git clone https://github.com/yart/pingmeter.git
$ cd pingmeter
$ docker-compose up
```

Then go to http://localhost. If your system cannot share you localhost:80 try to edit docker-compose.yaml ar row 11
and change 80 to any port you want.

## How to use

The application receives IP-addresses (one address per one time) then it ping them every 1 second and store the results
to a database. You can start and stop the measurements every time you want. To start/stop an IP-address measurement you 
can as use the forms on the web page as use browser's search-string. If you wish to use browser's search-string use 
follows format please:

1. to put IP-address you need write something like: http://localhost/add?ip=1.2.3.4
2. to delete IP-address you can write follows: http://localhost/remove?ip=1.2.3.4
3. to request your IP-addresses statistics put to browser's search-string
something like this: /statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00

The app will return you a JSON with results of measurements. It measures mean RTT, min and max RTT, median RTT, standard
deviation of RTT and percent of measurement fails on period you pointed.

![image](https://user-images.githubusercontent.com/470045/122862062-37e7f380-d329-11eb-8d9b-9ee45e886546.png)

## Known problems and issues

- The service needs to be improved to better stabylity of work.
- Also it has some troubles with security. For example it doesn't control requests and users can send all they want. 
- Docker images keep all information self inside so it needs to be added docker volumes to prevent information loss
  after restart.
- Also it needs to add a tool to check on exist the table 'addresses' and if it exists need to run at system start
  all pings that have status 'deleted' equale to 0.
- PingMeter ping daemons need to be started at personal container each.
- API needs to be expanded with at least method for receiving runned pings list.
