# iPhone: free 7-day sideload

## Spec (Jack, 2026-10-25)

如果我只是要test看看好不好用，我完全可以在不麻烦他的情况下先用完全免费的版本，就是用普通apple id那个对吧？真的ok了，才用朋友的，才去testflight，才申请上app store？

OK先走免费test 7天的路。就照这个开始吧。
其他要要求朋友的先搁置。
接下来怎么做。

## Decisions

- D1. Free route first: an unsigned `.ipa` built on a cloud Mac, signed and
  installed from Windows with Sideloadly and Jack's own Apple ID. Anything
  that needs the friend's account is on hold.

## Tasks

- [ ] 1. Redesign confirmed, swept, committed; folder made a git repo and
      pushed to a public GitHub repo.
- [x] 2. iOS project ready: display name, bundle ID, launch screen colour,
      deployment target if a package needs a newer one. (Display name
      `Expenses` on both phones; launch colour follows light/dark; bundle ID
      kept `com.jack.expenseTracker`; target stays 12.0 unless the build says
      otherwise.)
- [ ] 3. GitHub Actions workflow builds an unsigned `.ipa` on macOS with
      Flutter 3.32.0 and keeps it as a download.
- [ ] 4. Jack installs Sideloadly and Apple's iPhone driver on Windows.
- [ ] 5. Jack signs and installs the `.ipa` with his Apple ID; Developer Mode
      on, profile trusted; app opens on the iPhone.
- [ ] 6. Re-sign routine every 7 days, with an Export JSON backup first.
