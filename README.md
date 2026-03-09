# Dzenn - Pomodoro & Timer

<video src="https://res.cloudinary.com/dctl5pihh/video/upload/v1773037353/dzenn-final_ycbwue.mov" controls width="3600"></video>

> An open-source floating timer with image support

A minimal timer designed to stay out of your way. Set a duration with the slider
or by typing minutes. You can also show an image in the floating timer, either
as a gentle companion for focus or a simple visual reminder.

## Background

It was the last 10 days of Ramadan. While everyone else was busy at the mosque securing their spiritual gains, I was... well, stuck doing _work_. I thought to myself, "How do I keep grinding but still remember to pray?" So I built a Pomodoro timer that supports custom images! Now I can have constant visual reminders to keep my hustle and my faith perfectly balanced.

## Features

- Floating timer: Dzenn can pin a compact always-on-top timer window so countdown progress stays visible without keeping the main window open.
- 3 display modes: the floating window supports `timer only`, `image with timer`, and `image only`, with layout switching handled at runtime.
- Quick presets: menu bar presets let you jump to commonly used focus durations instantly, then start a session without opening full settings.
- Completion sound customization: you can choose the alert sound used when a session finishes and control playback behavior through app settings.
- Floating opacity control: the floating window appearance supports adjustable opacity so it can stay visible but less intrusive over other apps.
- Image positioning: when using image layouts, image offset controls let you fine-tune placement so composition remains readable with timer overlay.


## Install

1. Go to Releases.
2. Download the appropriate DMG file:
   - Apple Silicon (M1/M2/M3/M4/M5): `dzenn_*_mac-arm64.dmg`
   - Intel: `dzenn_*_mac-intel.dmg`
3. Open the DMG and drag Dzenn to Applications.
4. First Launch - Choose one method (recommended):
   - Option A: Right-Click Method (Easiest)
     Right-click the app -> Open -> Click Open in the dialog.
   - Option B: Terminal Method (One command, no dialogs) (recommended)
     `xattr -d com.apple.quarantine /Applications/Dzenn.app`
5. Grant permission from **System Settings > Privacy & Security** if macOS still shows a launch warning.

```bash
Note: This is an ad-hoc signed indie app. macOS shows a warning for apps not notarized through Apple's $99/year developer program. The app is completely safe and open source.
```

<!-- ## Manual Install

- Click to Download
- Open Dzenn.dmg (double click)
- "Dzenn.app can't be opened because it is from an unidentified developer"
  will appear, press OK
- Open System Settings
- Select Privacy & Security
- On the bottom side, select Open Anyway -->

<!-- ## Homebrew

- Open terminal
- Enter: `brew install --cask dzenn-pomodoro`

## Uninstallation

Manual
- Delete Dzenn.app from `/Applications`

Homebrew
- Open terminal
- Enter: `brew uninstall --cask dzenn-pomodoro` -->

## Compatibility

Requires macOS 15.6 or above.

## License

BSD 3-Clause
