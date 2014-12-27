on run argv
  set appleId to item 1 of argv
  set applePassword to item 2 of argv
  set appleSource to "macappstores://itunes.apple.com/app/" & item 3 of argv

  tell application "Finder" to open location appleSource

  delay 5

  tell application "System Events" to tell process "App Store"
    set frontmost to true
    tell window "App Store"
      UI elements

      set loaded to false

      repeat until loaded = true
        try
          -- log "Trying to load"
          delay 3
          set installButtonContainer to group 1 of group 1 of UI element 1 of scroll area 1 of group 1 of group 1
          set installButton to button 1 of installButtonContainer
          set loaded to true
        on error
          -- delay 1
          do shell script "killall 'App Store'"
          error "Error loading applicaiton"
        end try
      end repeat

      if description of installButton does not start with "Install," then
        if description of installButton starts with "Open" then
          tell application "App Store" to quit
          return
        end if
        error "Can't find install button"
      end if

      -- log "Clicking install button"
      click installButton
      repeat while description of installButton starts with "Install,"
        -- log "Waiting for install button to leave"
        delay 1
        set installButton to button 1 of installButtonContainer
      end repeat
      -- log "Install button clicked successfully"

      if description of installButton starts with "Confirm," then
        log "Clicking confirmation button"
        click installButton
        log "Waiting for confirmation button to leave"
        delay 2
        set installButton to button 1 of installButtonContainer
      end if
      -- log "Confirmation button clicked successfully (if applicable)"

      set needToAuthenticate to false
      try
        -- log "Looking for auth window"
        # We should now be looking at a modal pop-down dialog for credentials.
        set appleIdBox to text field 2 of sheet 1
        set applePasswordBox to text field 1 of sheet 1
        set signInButton to button 1 of sheet 1

        set needToAuthenticate to true
      on error
        # We may not be prompted for creds at all
        -- log "Did not find auth window"
      end try
      -- log "Done looking for auth window"

      if needToAuthenticate = true then
        log "Authenticating"
        set value of attribute "AXValue" of appleIdBox to appleId
        set value of attribute "AXFocused" of appleIdBox to appleId
        keystroke tab
        set value of attribute "AXValue" of applePasswordBox to applePassword
        delay 2
        --log "Clicking sign in button"
        click signInButton
      end if

      repeat while description of installButton starts with "Confirm,"
        log "Waiting for confirmation button to leave"
        delay 2
        set installButton to button 1 of installButtonContainer
      end repeat
      -- log "Installing"

      if {description of installButton does not start with "Installing," and description of installButton does not start with "Open," and description of installButton does not start with "Installed,"} then
        tell application "App Store" to quit
        error "Could not start install."
      end if

      repeat while description of installButton starts with "Installing,"
        -- log "Waiting for install to finish"
        delay 5
        set installButton to button 1 of installButtonContainer
      end repeat
      -- log "Install finished"

      if description of installButton starts with "Install," then
        tell application "App Store" to quit
        error "Install paused or cancelled"
      else if {description of installButton does not start with "Open," and description of installButton does not start with "Installed,"} then
        tell application "App Store" to quit
        error "Unknown error during installation"
      end if
    end tell
  end tell

  tell application "App Store" to quit
end run
