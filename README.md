# yddcutil

# Version:    0.0.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/yddcutil
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
yddcutil aims to be a basic universal GUI for managing compliant DCC monitors settings.
It takes advantage of ddcutil for query and change monitor settings, and yad is used for the graphical interface, so in order
to use yddcutil you must have yad and ddcutil on your system first.
Please be sure to have a working ddcutil setup before trying yddcutil. Refer to http://www.ddcutil.com

yddcutil is at very early stage, just a minority (the most important I think) of DDC features are implemented right now, including
some that I can't test.
If You want some feature to be implemented, for reporting bugs, give tips ecc... please open an issue at
https://github.com/KeyofBlueS/yddcutil/issues

### TODO
- Make our own icon set for the graphical interface, I ask you for help on this
- Implement all possible functions, even here I need Your collaboration

### INSTALL
```sh
curl -o /tmp/yddcutil.sh 'https://raw.githubusercontent.com/KeyofBlueS/yddcutil/master/yddcutil.sh'
sudo mkdir -p /opt/yddcutil/
sudo mv /tmp/yddcutil.sh /opt/yddcutil/
sudo chown root:root /opt/yddcutil/yddcutil.sh
sudo chmod 755 /opt/yddcutil/yddcutil.sh
sudo chmod +x /opt/yddcutil/yddcutil.sh
sudo ln -s /opt/yddcutil/yddcutil.sh /usr/local/bin/yddcutil
```
### USAGE
```sh
$ yddcutil
```
```
Options:
-b, --bus <bus-number>		I2C bus number
-s, --sleep-multiplier <VALUE>	Applies a multiplication factor to the DDC/CI specified sleep times
-h, --help			Show this help
```
