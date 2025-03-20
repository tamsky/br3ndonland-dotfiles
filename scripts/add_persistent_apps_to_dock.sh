#!/usr/bin/env bash
#
#   file:
#       add_persistent_apps_to_dock.sh
#
#   function:
#       add specified application bundle(s) to Dock as persistent application(s)
#
#   usage:
#       ./add_persistent_apps_to_dock.sh file [file ...]
#
#           file : absolute posix path of application bundle
#
#   version:
#       0.10
#
#   source:
#       https://discussions.apple.com/thread/7538664
#
#   author: Hiroto
#
shopt -s extglob
for f in "$@"; do
  # normalise bundle path so that it ends with /
  f=${f/%+(\/)/}/
  # quote meta characters for regex
  fq=$(sed 's/[^[:alnum:]]/\\&/g' <<<"$f")

  CFURLStringType=0
  egrep -q '^file://' <<<"${f}" && CFURLStringType=15

  [[ -n $(defaults read com.apple.dock persistent-apps |
    sed -En "s/\"_CFURLString\" = \"?($fq)\"?;/\1/p") ]] && continue # already exists

  defaults write com.apple.dock persistent-apps -array-add "
<dict>
    <key>tile-data</key>
    <dict>
        <key>file-data</key>
        <dict>
            <key>_CFURLString</key>
            <string>${f}</string>
            <key>_CFURLStringType</key>
            <integer>${CFURLStringType}</integer>
        </dict>
    </dict>
</dict>
"
done
killall Dock
