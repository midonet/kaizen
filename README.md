# Kaizen 改善

This is a script to be used by field service personnel to run a couple of checks on a MidoNet OpenStack cloud.

After uploading the script to a controller or a compute node you can run it manually, it will autodetect the server based on what services are installed.

If you have fabric installed on your PC you can also run the script automatically on a couple of servers.

To do this you should edit conf/servers.txt and run the Makefile that is included in this directory.

But the shell script itself is designed to run automatically and stand-alone.

Fabric is used only for uploading and executing, no check logic will be included in fabric itself.
