#!/bin/bash
#
# Copyright 2015 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# can remove next line if already updated....
sudo apt-get update
#sudo rm -rf /usr/local/lib/node_modules/
#sudo rm -rf /usr/local/bin/node-red*
sudo rm -rf /usr/lib/node_modules/
sudo rm -rf /usr/bin/node-red*
sudo rm -rf /home/pi/.npm /home/pi/.node-gyp
sudo rm -rf /root/.npm /root/.node-gyp
sudo apt-get install nodejs nodejs-legacy npm lintian -y
sudo npm install -g npm@2.x
hash -r
sudo npm cache clear
echo " "
echo "Installed"
echo "   Node" $(node -v)
echo "   Npm   "$(npm -v)
echo "Now installing Node-RED - please wait - can take 10 mins on a Pi 1"
echo "   Node-RED "$(npm show node-red version)
sudo npm install -g --unsafe-perm node-red

# Remove a load of unnecessary doc/test/example from pre-reqs
pushd /usr/lib/node_modules/node-red/node_modules
sudo find . -type d -name test -exec rm -r {} \;
sudo find . -type d -name doc -exec rm -r {} \;
sudo find . -type d -name example* -exec rm -r {} \;
sudo find . -type d -name sample -exec rm -r {} \;
sudo find . -type d -iname benchmark* -exec rm -r {} \;
sudo find . -type d -iname .nyc_output -exec rm -r {} \;
sudo find . -type d -iname unpacked -exec rm -r {} \;

sudo find . -name bench.gnu -type f -exec rm {} \;
sudo find . -name .npmignore -type f -exec rm {} \;
sudo find . -name .travis.yml -type f -exec rm {} \;
sudo find . -name .jshintrc -type f -exec rm {} \;
sudo find . -iname README.md -type f -exec rm {} \;
sudo find . -iname HISTORY.md -type f -exec rm {} \;
sudo find . -iname CONTRIBUTING.md -type f -exec rm {} \;
sudo find . -iname CHANGE*.md -type f -exec rm {} \;
sudo find . -iname .gitmodules -type f -exec rm {} \;
sudo find . -iname .gitattributes -type f -exec rm {} \;
sudo find . -iname .gitignore -type f -exec rm {} \;
sudo find . -iname "*~" -type f -exec rm {} \;
# slightly more risky
sudo find . -iname test* -exec rm -r {} \;
popd

# Add some extra useful nodes
mkdir -p ~/.node-red
sudo npm install -g node-red-admin
echo "Node-RED installed. Adding a few extra nodes"
sudo npm install -g node-red-node-rbe node-red-node-random node-red-node-ping node-red-node-smooth node-red-node-ledborg
#npm install node-red-contrib-scx-ibmiotapp

match='uiPort: 1880,'
file='/usr/lib/node_modules/node-red/settings.js'
insert='\n    editorTheme: { menu: { \"menu-item-help": {\n        label: \"Node-RED Pi Website\",\n        url: \"http:\/\/nodered.org\/docs\/hardware\/raspberrypi.html\"\n    } } },\n'
sudo sed -i "s/$match/$match\n$insert/" $file
echo "**** settings.js ****"
head -n 32 /usr/lib/node_modules/node-red/settings.js
echo "*********************"

# Get systemd script - start and stop scripts - svg icon - and .desktop file into correct places.
if [ -d "resources" ]; then
    cd resources
    sudo chown root:root *
    sudo chmod +x node-red-st*
    sudo chmod -x update-nodejs-and-nodered
    sudo cp nodered.service /lib/systemd/system/
    sudo cp node-red-start /usr/bin/
    sudo cp node-red-stop /usr/bin/
    sudo cp update-nodejs-and-nodered /usr/bin/
    sudo cp node-red-icon.svg /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
    sudo chmod 644 /usr/share/icons/gnome/scalable/apps/node-red-icon.svg
    sudo cp Node-RED.desktop /usr/share/applications/Node-RED.desktop
    sudo chown pi:pi *
    cd ..
else
    echo " "
    echo "resources - subdirectory not in place... exiting."
    exit 1
fi
#sudo systemctl disable nodered

# Restart lxpanelctl so icon appears in menu - programming
lxpanelctl restart
echo " "
echo "All done."
echo "  You can now start Node-RED with the command node-red-start"
echo "  or using the icon under Menu / Programming / Node-RED."
echo "  Then point your browser to http://127.0.0.1:1880 or http://{{your_pi_ip-address}:1880"
echo " "
