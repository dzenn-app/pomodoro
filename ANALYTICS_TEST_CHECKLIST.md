# Analytics Manual Test Checklist

## Session Tracking

- [ ] Start focus session (quick session, 25m)
- [ ] Verify timer counts down correctly
- [ ] Switch between apps (Xcode → Safari → Finder)
- [ ] Open Chrome/Safari, browse 2-3 different domains
- [ ] Stop session manually before timer ends
- [ ] Check Analytics page appears
- [ ] Verify heatmap shows today with correct intensity
- [ ] Verify Day Overview shows:
  - [ ] Total Focus time matches session duration
  - [ ] Sessions count = 1
  - [ ] Interrupted count = 1 (since stopped early)
- [ ] Verify Breakdown shows:
  - [ ] Top Apps lists apps switched during session
  - [ ] Top Websites shows domains visited (if Automation permission granted)

## Multi-Session Day

- [ ] Complete 2-3 focus sessions in one day
- [ ] Let timer finish naturally (don't stop manually)
- [ ] Check Day Overview:
  - [ ] Total Focus = sum of all sessions
  - [ ] Sessions count = number of sessions
  - [ ] Completed count = sessions that finished naturally
  - [ ] Interrupted count = sessions stopped early
- [ ] Verify heatmap intensity increases with more focus time

## Heatmap Navigation

- [ ] Click different days in heatmap
- [ ] Verify Day Overview updates to selected day
- [ ] Verify Breakdown updates to selected day
- [ ] Verify "No sessions" message on days without data

## Permission States

- [ ] Fresh install (no permissions)
  - [ ] Analytics shows "No focus sessions yet"
  - [ ] Breakdown shows "Website tracking disabled" with button
  - [ ] Click button opens System Settings → Automation
- [ ] Grant Automation permission
  - [ ] Restart app
  - [ ] Run session with browser usage
  - [ ] Verify website domains appear in Breakdown

## Analytics Toggle

- [ ] Turn off analytics (UserDefaults: analyticsEnabled = false)
- [ ] Run focus session
- [ ] Verify no data saved (check JSON files)
- [ ] Turn analytics back on
- [ ] Run new session
- [ ] Verify new data appears

## Data Persistence

- [ ] Run multiple sessions over several days
- [ ] Quit app completely
- [ ] Relaunch app
- [ ] Verify all historical data still visible
- [ ] Verify heatmap shows full history
- [ ] Verify breakdown works for past days

## Edge Cases

- [ ] Session < 1 minute
- [ ] Session exactly 60 minutes
- [ ] Switch apps rapidly (every few seconds)
- [ ] Use unsupported browser (Firefox, Edge)
- [ ] Browser with no tabs open
- [ ] System sleep during session
- [ ] App crash mid-session, then relaunch

## Performance

- [ ] 100+ sessions in history
- [ ] Finalize session should complete < 1 second
- [ ] Analytics page load < 2 seconds
- [ ] No UI freezes when switching days
