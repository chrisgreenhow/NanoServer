# NanoServer
Scripts to simplify the creation of Nano Server VMs

## Nano-Create.ps1

This script will prompt for a new Nano Server name and Administrator password and will generate and start a new Hyper-V Nano Server configured for IIS.

## Nano-Setup.ps1

This script will prompt for the Nano Server name and will connect to the running Hyper-V VM and execute a Run-once setup script.


## Nano-CreateTP5.ps1

This script will prompt for a new Nano Server name and Administrator password and will generate and start a new Hyper-V Nano Server configured for IIS. This is an updated script for Nano Server Technical Preview 5, and doesn't require a post creation Setup script.
