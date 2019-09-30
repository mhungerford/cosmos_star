# Cosmo's Star
Cosmo's Star is the journey of Cosmo on planets with inhospitable life-forms, battling unknown creatures by ... matching 3 colored tiles.  

Unlike normal Match-3 games, there is no tile swapping.  The only way to move tiles is by finding matching monsters beneath the tiles, which causes those tiles to vanish and the above tiles to fall, and any 3 or more in a row/column will then vanish, powering up Cosmo's blaster.  When Cosmo's blaster is charged, he blasts the nearest alien, extending his journey.

## Resources
Resources were all found on http://OpenGameArt.org as listed below

Monster Icons by CraftPix.net
License: OGA-BY 3.0
https://opengameart.org/content/monster-2d-game-objects

Match-3 Tiles by Matriax
License: CC0
https://opengameart.org/content/match-3-tiles

Grotto Escape Characters and World Tiles by Ansimuz
License: CC0
https://opengameart.org/content/platform-pixel-art-assets

Mobile Game GUI Buttons by SetyByrd
License: CC0
https://opengameart.org/content/mobile-game-gui-buttons

Title Banner by pencilparker
License: Pixabay License
https://pixabay.com/illustrations/toys-astronaut-rocket-planet-3644073/

Icon Base by pencilparker
License: Pixabay License
https://pixabay.com/illustrations/sketch-cartoon-space-set-3045125/

## Building
This game is written in Qt/QML and compiles in Qt 5.6+
It can be built either by the Qt that ships with Ubuntu 16.04 or greater 
Or the Qt `Creator provided at: https://download.qt.io/official_releases/qt/5.13/5.13.1/

On Ubuntu:
```
sudo apt install build-essential
sudo apt install qt5-default qttools5-dev-tools qtmultimedia5-dev qtdeclarative5-dev 
sudo apt install qtbase5-private-dev
sudo apt install mesa-common-dev libgl1-mesa-dev
sudo apt install qtcreator

```
If the system is Ubuntu 16.04, needs the following backport:
```
sudo add-apt-repository ppa:kubuntu-ppa/backports 
sudo apt-get update
sudo apt-get dist-upgrade
```
Compilation commands (alternatively use qtcreator with cosmos_star.pro):
```
mkdir -p build
pushd build
qmake ../cosmos_star.pro
make
popd
```

