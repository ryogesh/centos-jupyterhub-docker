#!/usr/bin/python3
# -*- coding: utf-8 -*-

# An example jupyterhub config file with PAM/Localauthenticator and DockerSpawner in host network mode
c.JupyterHub.bind_url = 'https://jupyterhub.my.domain:443'
c.JupyterHub.cookie_max_age_days = 1
c.JupyterHub.log_level = 'INFO'
c.ConfigurableHTTPProxy.debug = False
c.DockerSpawner.debug = False
c.Spawner.debug = False

c.JupyterHub.ssl_key = '/etc/pki/tls/private/private.key'
c.JupyterHub.ssl_cert = '/etc/pki/tls/certs/public.crt'

c.JupyterHub.pid_file = '/etc/jupyterhub/jupyterhub.pid'
c.JupyterHub.db_url = 'sqlite:////etc/jupyterhub/jupyterhub.sqlite'
c.JupyterHub.cookie_secret_file = '/etc/jupyterhub/jupyterhub_cookie_secret'
c.PAMAuthenticator.open_sessions = False
c.JupyterHub.tornado_settings = {'slow_spawn_timeout': 60 }


# Custom spawner when docker container is run in host network mode
# Current versions of Docker supports init, hence no no need to install tini
# Both these are set as extra_host_config parameters
from jupyterhub.utils import random_port
from dockerspawner import DockerSpawner
class CustomSpawner(DockerSpawner):
    @property
    def internal_hostname(self):
        return 'jupyterhub.my.domain'
        
    def _port_default(self):
        return random_port()

c.JupyterHub.spawner_class = CustomSpawner
c.Spawner.mem_limit = '2G'
c.Spawner.http_timeout = 60
c.Spawner.start_timeout = 60
c.DockerSpawner.image = 'centos-pyspark-r:latest'
c.DockerSpawner.extra_host_config = {'network_mode': 'host', 'init': True}
c.DockerSpawner.volumes = {'jupyterhub-user-{username}': '/home/jpuser'}
c.DockerSpawner.remove = True
c.DockerSpawner.use_internal_hostname = True
c.DockerSpawner.host_ip = '0.0.0.0'

