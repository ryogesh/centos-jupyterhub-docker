# centos-jupyter-docker
Jupyter docker container with Python, R packages and crond scheduler


## Overview
This repository contains the Dockerfile and scripts to create a Jupyter docker container with the below components.

## Components
There are 3 main components
- Python3:  With Jupyterhub, jupyterlab, pyspark, scipy, seaborn and scikit-learn packages
- R: With data processing packages
- crond: To run jobs in the background from the container


## Configuration file

A sample jupyterhub configuration file, shows launching the container in host network mode and without tini.
A sample jupyter notebook configuration file is included in jupyter/conf folder.


## Building the image

```
docker build -t centos-pyspark-r:latest .
```


## Running cron jobs from the Docker Container
Creating the jobs using crontab in the container comes with a few caveats. Dockerfile has extensive comments.
To list the scheduled jobs, crontab -l can be used. But to edit the scheduler, do NOT use crontab -e. Instead, edit the file /var/spool/cron/jpuser directly using vi/echo/cat...

e.g. Run date command every 5 mins and output to /tmp/date.out file

```
echo "*/5 * * * * date >>/tmp/date.out" >> /var/spool/cron/jpuser
```
