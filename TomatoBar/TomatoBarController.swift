import Cocoa

public class TomatoBarController: NSViewController {
    /** Is sound enabled flag */
    private var isSoundEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "isSoundEnabled")
    }

    /** Interval length, in minutes */
    private var intervalLength: Int {
        return UserDefaults.standard.integer(forKey: "intervalLength")
    }
    /** Interval length as seconds */
    private var intervalLengthSeconds: Int { return intervalLength * 60 }

    /** Time left, in seconds */
    private var timeLeft: Int = 0
    /** Time left as MM:SS */
    private var timeLeftString: String {
        return String(format: "%.2i:%.2i", timeLeft / 60, timeLeft % 60)
    }
    /** Timer instance */
    private var timer: DispatchSourceTimer?

    /** Status bar item */
    public var statusItem: NSStatusItem?
    /** Status bar button */
    private var statusBarButton: NSButton? {
        return statusItem?.button
    }

    @IBOutlet private var statusMenu: NSMenu!
    @IBOutlet private var touchBarItem: NSTouchBarItem!
    @IBOutlet private var touchBarButton: NSButton!
    @IBOutlet private var startMenuItem: NSMenuItem!
    @IBOutlet private var stopMenuItem: NSMenuItem!
    @IBOutlet private var isSoundEnabledCheckBox: NSButton!

    /* Loaded because of fake view */
    override public func viewDidLoad() {
        super.viewDidLoad()
        /* Register defaults */
        UserDefaults.standard.register(defaults: ["intervalLength": 25,
                                                  "isSoundEnabled": true])

        /* Initialize status bar */
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.alignment = .right
        statusBarButton?.image = NSImage(named: NSImage.Name("BarIcon"))
        statusBarButton?.imagePosition = .imageOnly
        statusItem?.menu = statusMenu

        /* Initialize touch bar, WARNING: uses private framework methods */
        NSTouchBarItem.addSystemTrayItem(touchBarItem)
        DFRElementSetControlStripPresenceForIdentifier(touchBarItem.identifier.rawValue, true)
    }

    /** Called on Touch Bar button and Start and Stop menu items clicks */
    @IBAction private func startStopAction(_ sender: Any) {
        if timer == nil {
            playSound()
            start()
        } else {
            playSound()
            finish()
        }
    }

    /** Starts timer */
    private func start() {
        touchBarButton.imagePosition = .noImage
        statusBarButton?.imagePosition = .imageLeft
        swap(&startMenuItem.isHidden, &stopMenuItem.isHidden)
        statusItem?.length = 70
        timeLeft = intervalLengthSeconds
        let queue: DispatchQueue = DispatchQueue(label: "Timer")
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .never)
        timer?.setEventHandler(handler: self.tick)
        timer?.resume()
    }

    /** Called on finish */
    private func finish() {
        timer?.cancel()
        timer = nil
        touchBarButton.imagePosition = .imageOnly
        statusBarButton?.imagePosition = .imageOnly
        swap(&startMenuItem.isHidden, &stopMenuItem.isHidden)
        statusItem?.length = NSStatusItem.variableLength
    }

    /** Called every second by timer */
    private func tick() {
        timeLeft -= 1
        DispatchQueue.main.async {
            if self.timeLeft >= 0 {
                self.touchBarButton.title = self.timeLeftString
                self.statusBarButton?.title = self.timeLeftString
            } else {
                self.playSound()
                self.finish()
                /* Send notification */
                let notification: NSUserNotification = NSUserNotification()
                notification.title = "Time's up"
                notification.informativeText = "Keep up the good work!"
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }

    /** Plays sound */
    private func playSound() {
        guard isSoundEnabled else {
            return
        }
        NSSound.beep()
    }

}
