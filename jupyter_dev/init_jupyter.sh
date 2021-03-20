#!/bin/sh
# Jupyter Environment Lauch Script for Convenience

nix-shell --command "jupyter lab --KernelSpecManager.whitelist=\"['ipython_python3']\" --LabApp.password="'sha1:7d1c865501af:340749d7729044c48cd64621e53659c0b0bee16a'""

# run command in shell to initialize password:
# from notebook.auth import passwd; passwd(your_password_here)
