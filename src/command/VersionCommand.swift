struct VersionCommand: Command {
    let info: CmdStaticInfo = VersionCmdArgs.info

    func _run(_ subject: inout CommandSubject, _ stdout: inout String) -> Bool {
        check(Thread.current.isMainThread)
        stdout += "\(Bundle.appVersion) \(gitHash)\n"
        return true
    }
}
