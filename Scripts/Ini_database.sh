#!/bin/bash

database_ini="../Sql/database.ini"
touch $database_ini

read -p "Please enter your PostgreSQL user: " psql_username
read -s -p "Please enter $psql_username's password: " psql_password
echo

echo -n "[postgresql]
host=localhost
database=product_details
user=$psql_username
password=$psql_password" > $database_ini