#!/usr/bin/osascript

on run argv
  set appleId to item 1 of argv
  set applePassword to item 2 of argv

  -- open iCloud.prefPane
  tell application "System Preferences"
    activate
    set the current pane to pane id "com.apple.preferences.icloud"
  end tell

  tell application "System Events"
    tell process "System Preferences"
      tell window 1
        tell group 1
          tell button "Sign in"
            if not (exists) then
              error "Couldn't find Sign in button. Already signed in to iCloud?"
            end if
          end tell

          set value of text field 2 to appleId
          set value of text field 1 to applePassword

          -- This hack is needed because the Sign In button is disabled still
          set value of attribute "AXFocused" of text field 2 to true
          delay 1
          key code 124
          delay 1
          -- Yosemite doesn't allow space but it does enale the Sign In button
          -- El Cap does allow so a backspace is needed
          keystroke " "

          click button "Sign In"

          repeat until exists button "Next"
            delay 1
          end repeat

          click button "Next"
        end tell

        tell sheet 1
          repeat until exists button "Allow"
            delay 1
          end repeat

          click button "Allow"

          repeat until exists button "Not Now"
            delay 1
          end repeat

          click button "Not Now"

          repeat until exists button "OK"
            delay 1
          end repeat

          set value of text field 1 to applePassword
          click button "OK"

          repeat until exists button "Request Approval"
            delay 1
          end repeat

          click button "Request Approval"

          repeat until exists button "OK"
            delay 1
          end repeat

          click button "OK"
        end tell

        -- TODO: Remove once iCloud Photo Library script set up
        -- Disable iCloud Photo Library as needs to be enabled in iPhoto
        -- tell group 1
        --   tell scroll area 1
        --     tell table 1
        --       tell row 2
        --         tell UI element 1
        --           click button "Options…"
        --           delay 1
        --         end tell
        --       end tell
        --     end tell
        --   end tell
        -- end tell

        -- tell sheet 1
        --   click checkbox 1
        --   delay 1
        --   click button "Done"
        -- end tell
      end tell
    end tell
  end tell

  tell application "System Preferences" to quit
end run
