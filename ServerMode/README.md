### Running the Server Mode for Ashaninka_Morph

```
# Clone AshaninkaMorph repository
$ git clone https://github.com/hinantin/AshaninkaMorph
# Clone AllinQillqay Repository
$ git clone https://github.com/hinantin/AllinQillqayWeb
$ cd AllinQillqayWeb/ServerSide/SQUOIA/foma/
# Compile foma 
$ sudo apt-get install zlib1g-dev flex bison libreadline-dev
$ make 
$ sudo make install
# Installing the Foma server 
$ sudo cp fomaserver /usr/bin/
$ sudo chmod +x /usr/bin/fomaserver

# Got to the AshaninkaMorph folder 
$ cd AshaninkaMorph
$ foma -f asheninka.script
# Creating the HINANTIN folder
$ sudo mkdir -p /usr/share/hinantin/
# Installing transducers
$ sudo cp asheninka.bin /usr/share/hinantin/

```
