The Microsoft Surface Thunderbolt(TM) 4 Dock Audio device gets glitched once the Mac goes to sleep or is disconnected and connected.

### Symptoms:

- No sound on that device, obviously
- Applications that list audio devices hang
- Applications that reproduce sound can hang

### Easily reproducible:

- Audio Midi Setup: long time to open, shows Microsoft Surface Thunderbolt(TM) 4 Dock Audio (1 & 2) without available formats
- Screenshot: long time to open, you'll forget you've triggered it using a key combination

# Workaround

### Working

- Restart the Mac
- Restart `coreaudiod`

### Not working

- Restarting the dock does not fix the issue

# Solution

This is a daemon that will launch and keep running, listening for sleep and wake events as well as audio device changes.
 - Once the Mac goes to sleep the daemon will take note and upon wake, if the dock is connected, will restart `coreaudiod`.
 - If it detects an audio device change and finds the dock is connected it will restart `coreaudiod`.

While checking if the dock is pressent in the audio devices and if it has formats available, to prevent the restart of `coreaudiod` if it's not needed, checking the audio devices will also trigger the hang, so the daemon will loose it's purpose being unresponsive for a minute or so.

# Installation

Compile the project, place the executable near the `Daemon/install` and then execute `Daemon/install`.