#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os

# Set appropriate umask
os.umask(0o022)

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False
