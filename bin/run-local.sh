#!/bin/bash

kill $(lsof -ti :3035) $(lsof -ti :5504)

foreman start --procfile=Procfile.local  --env=
