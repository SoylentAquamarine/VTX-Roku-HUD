sub init()
    m.image = m.top.findNode("hudImage")
    m.status = m.top.findNode("statusLabel")
    m.timer = m.top.findNode("rotateTimer")
    m.task = m.top.findNode("fetchPagesTask")

    m.configPanel = m.top.findNode("configPanel")
    m.configTitle = m.top.findNode("configTitle")
    m.configHelp = m.top.findNode("configHelp")
    m.configFooter = m.top.findNode("configFooter")
    m.keyboard = m.top.findNode("serverKeyboard")

    m.pages = []
    m.currentIndex = 0
    m.paused = false
    m.configOpen = false
    m.pagesPath = "/api/pages"

    LoadSettings()

    m.timer.ObserveField("fire", "OnRotateTimer")
    m.task.ObserveField("result", "OnPagesResult")
    m.task.ObserveField("error", "OnPagesError")

    FetchPages()
    m.timer.control = "start"
    m.top.SetFocus(true)
end sub

sub LoadSettings()
    reg = CreateObject("roRegistrySection", "VtxRokuHud")
    m.serverUrl = reg.Read("serverUrl")
    if m.serverUrl = invalid or m.serverUrl = "" then m.serverUrl = "http://192.168.1.50:8080"

    rotateText = reg.Read("rotateSeconds")
    if rotateText <> invalid and rotateText <> "" then
        m.timer.duration = Val(rotateText)
    else
        m.timer.duration = 15
    end if
end sub

sub SaveSettings()
    reg = CreateObject("roRegistrySection", "VtxRokuHud")
    reg.Write("serverUrl", m.serverUrl)
    reg.Write("rotateSeconds", m.timer.duration.ToStr())
    reg.Flush()
end sub

sub FetchPages()
    m.status.text = "Loading pages from " + m.serverUrl
    m.task.serverUrl = m.serverUrl
    m.task.pagesPath = m.pagesPath
    m.task.control = "RUN"
end sub

sub OnPagesResult()
    data = m.task.result
    if data = invalid then return

    if data.rotateSeconds <> invalid then m.timer.duration = data.rotateSeconds
    if data.pages <> invalid then
        m.pages = data.pages
        m.currentIndex = 0
        ShowCurrentPage()
        SaveSettings()
    else
        m.status.text = "No pages array returned by server"
    end if
end sub

sub OnPagesError()
    if m.task.error <> invalid and m.task.error <> "" then
        m.status.text = m.task.error
    end if
end sub

sub ShowCurrentPage()
    if m.pages.Count() = 0 then
        m.status.text = "No HUD pages configured. Press * for settings."
        return
    end if

    page = m.pages[m.currentIndex]
    if Type(page) = "roAssociativeArray" then
        pageUrl = page.url
        title = page.title
    else
        pageUrl = page
        title = "Page " + (m.currentIndex + 1).ToStr()
    end if

    if pageUrl = invalid or pageUrl = "" then return
    if Left(LCase(pageUrl), 4) <> "http" then pageUrl = JoinUrl(m.serverUrl, pageUrl)

    m.image.uri = pageUrl

    state = "rotating"
    if m.paused then state = "paused"
    m.status.text = title + "  [" + (m.currentIndex + 1).ToStr() + "/" + m.pages.Count().ToStr() + "]  " + state
end sub

sub OnRotateTimer()
    if m.paused or m.configOpen then return
    NextPage()
end sub

sub NextPage()
    if m.pages.Count() = 0 then return
    m.currentIndex = (m.currentIndex + 1) mod m.pages.Count()
    ShowCurrentPage()
end sub

sub PrevPage()
    if m.pages.Count() = 0 then return
    m.currentIndex = m.currentIndex - 1
    if m.currentIndex < 0 then m.currentIndex = m.pages.Count() - 1
    ShowCurrentPage()
end sub

sub TogglePause()
    m.paused = not m.paused
    ShowCurrentPage()
end sub

sub ToggleConfig()
    m.configOpen = not m.configOpen
    m.configPanel.visible = m.configOpen
    m.configTitle.visible = m.configOpen
    m.configHelp.visible = m.configOpen
    m.configFooter.visible = m.configOpen
    m.keyboard.visible = m.configOpen

    if m.configOpen then
        m.keyboard.text = m.serverUrl
        m.keyboard.SetFocus(true)
        m.status.text = "Settings open"
    else
        m.top.SetFocus(true)
        ShowCurrentPage()
    end if
end sub

sub SaveConfigAndReload()
    m.serverUrl = m.keyboard.text
    SaveSettings()
    ToggleConfig()
    FetchPages()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.configOpen then
        if key = "OK" then
            SaveConfigAndReload()
            return true
        else if key = "back" or key = "options" then
            ToggleConfig()
            return true
        end if
        return false
    end if

    if key = "right" or key = "fastforward" then
        NextPage()
        return true
    else if key = "left" or key = "rewind" then
        PrevPage()
        return true
    else if key = "play" then
        TogglePause()
        return true
    else if key = "OK" then
        ShowCurrentPage()
        return true
    else if key = "options" then
        ToggleConfig()
        return true
    end if

    return false
end function

function JoinUrl(base as string, path as string) as string
    if Right(base, 1) = "/" and Left(path, 1) = "/" then
        return Left(base, Len(base) - 1) + path
    end if
    if Right(base, 1) <> "/" and Left(path, 1) <> "/" then
        return base + "/" + path
    end if
    return base + path
end function
