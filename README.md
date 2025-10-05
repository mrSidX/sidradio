# sidradio


INSTALL:

clone this repo to a folder in your user ~/<folder>

Run sudo ./install.sh to setup the HTTP server and permissions

Follow the wizard:
-service name creates a service for Linux (Ubuntu/Debian)
-Name of your Radio (This just populates the html template with the name)
-enter the URL/domain ... ie: live.myradiostation.com

This is setup and done.. You may need to configure apache/nginx for domain name stuff

Start the service : sudo systemctl start <name of your linux service>


Your folder ie (whatever folder you named and copied into):  ~/myradio/
make a dir : ~/myradio/music/beta (this is beta)

Check make sure permissions are set on your folders:

In this case the repo was cloned to "sid-live" folder:
cd ~/sid-live/music/beta
sudo chown -R sid:sid ~/sid-live
sudo chmod -R 755 ~/sid-live
~/sid-live/fixencode-aac.sh

sudo apt install inotify-tools
nohup ~/sid-live/watch_music.sh &


Dependencies required:

ffmpeg (install it in your linux )
inotify-tools : sudo apt install inotify-tools



Setup:


nohup ~/sid-live/watch_music.sh &

make a music/beta folder in the root folder
make an "incoming" folder in the beta folder
the watch_music.sh script will detect files placed in the incoming folder and convert them automatically.

sudo systemctl restart sidradio   (example with sidradio as the service name)
sudo systemctl status sidradio
