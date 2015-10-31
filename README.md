# kaizen
check a MidoNet OpenStack cloud for common configuration mistakes

This is a script to be used by field service personnel to run a couple of checks on a MidoNet OpenStack cloud.

After uploading the script to a controller or a compute node you can run it manually, it will autodetect the server based on what services are installed.

If you have fabric installed you can also run the script automatically on a couple of servers, for this you should edit conf/servers.txt and run the Makefile that is included in this directory.
