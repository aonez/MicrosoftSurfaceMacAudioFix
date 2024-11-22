The Microsoft Surface Thunderbolt(TM) 4 Dock Audio device gets glitched once the Mac goes to sleep.

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

This is a daemon that will launch and keep running, listening for sleep and wake events.
Once the Mac goes to sleep the daemon will take note and upon wake, if the dock is connected, will restart `coreaudiod `.

# Installation

Compile the project, place the executable near the `Daemon/install` and then execute `Daemon/install`.