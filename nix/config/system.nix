ctx:
ctx.linux-mac null {
  configurationRevision = ctx.self.rev or ctx.self.dirtyRev or null;
  defaults = {
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 0.5;
      "com.apple.sound.beep.sound" = null;
    };
    CustomSystemPreferences = { };
    CustomUserPreferences = { };
    LaunchServices.LSQuarantine = true;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleMeasurementUnits = "Inches";
      AppleMetricUnits = 0;
      AppleScrollerPagingBehavior = true;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      AppleShowScrollBars = "Always";
      AppleTemperatureUnit = "Fahrenheit";
      AppleWindowTabbingMode = "fullscreen";
      InitialKeyRepeat = 1;
      KeyRepeat = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = true;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = true;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = true;
      NSDisableAutomaticTermination = null;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSScrollAnimationEnabled = false;
      NSTableViewDefaultSizeMode = 1;
      NSTextShowsControlCharacters = true;
      NSUseAnimatedFocusRing = true;
      NSWindowResizeTime = 0.1;
      NSWindowShouldDragOnGesture = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      _HIHideMenuBar = false;
      "com.apple.keyboard.fnState" = true;
      "com.apple.mouse.tapBehavior" = null;
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.sound.beep.volume" = 1.0;
      "com.apple.springing.delay" = 0.1;
      "com.apple.springing.enabled" = true;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.trackpad.scaling" = 3.0;
      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
    };
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    WindowManager = {
      # Really, these are all about Stage Manager
      AppWindowGroupingBehavior = false;
      AutoHide = false; # true;
      EnableStandardClickToShowDesktop = true;
      GloballyEnabled = true; # Enables Stage Manager universally
      HideDesktop = true;
      StageManagerHideWidgets = true;
      StandardHideDesktopIcons = true;
      StandardHideWidgets = true;
    };
    alf = {
      allowdownloadsignedenabled = 0;
      allowsignedenabled = 0;
      globalstate = 1;
      loggingenabled = 1;
      stealthenabled = 1;
    };
    dock = {
      enable-spring-load-actions-on-all-items = true;
      appswitcher-all-displays = true;
      autohide = false; # true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.1;
      dashboard-in-overlay = true;
      expose-animation-duration = 0.1;
      expose-group-by-app = false;
      largesize = null;
      launchanim = true;
      magnification = false;
      mineffect = "genie";
      minimize-to-application = false;
      mouse-over-hilite-stack = true;
      mru-spaces = true;
      orientation = "bottom";
      persistent-apps = [
        "/System/Applications/System Settings.app"
        "/Applications/Nix Apps/Spotify.app"
        "/System/Applications/Messages.app"
        "/Applications/Nix Apps/Discord.app"
        "/Applications/Spark.app"
        "/Applications/Nix Apps/Slack.app"
        "/System/Applications/Notes.app"
        "/System/Applications/Reminders.app"
        "/Applications/Arc.app"
        "/Applications/Notion Calendar.app"
        "/Applications/Nix Apps/kitty.app"
        "/Applications/Logseq.app"
      ];
      persistent-others = [ ];
      show-process-indicators = true;
      show-recents = false;
      showhidden = true;
      static-only = false;
      tilesize = 16;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };
  };
}
