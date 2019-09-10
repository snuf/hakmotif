#!/usr/bin/python
#
import subprocess

r = subprocess.check_output(["git", "ls-remote"])
print r
