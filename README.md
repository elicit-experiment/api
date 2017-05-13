# Cockpit API
Ruby on Rails Web API for Cockpit experiments. 
- Can send POST requests to localhost:3000/experiments by using JSON, XML or plain HTML
- Can send GET requests to localhost:3000/experiments, /experiments.json, or /experiments.xml to see all experiments in the specified format
- Models, Views and Controllers can be found in separate folders in `/Cockpit_API/app/`

#Requirements:
- Ruby version 2.3.0
- Rails version 5.0.1 (not backward compatible with previous versions)
- SQL server running(I used XAMPP MySQL) as per `/Cockpit_API/config/database.yml`
** remember to change username, password, host, socket, database_name to values used in SQL server

#How to run:
- change directory to Cockpit_API: `cd /Cockpit_API/`
- run bundle to install dependencies: `bundle`
- start the webserver (default localhost:3000): `rails server`

#To do list(incomplete):
- find out how to communicate with the UI/Typescript server
- add the remaining models (based on the wanted database structure)
- add security