#!/bin/bash
bundle exec rake db:migrate:reset
bundle exec rake db:seed 