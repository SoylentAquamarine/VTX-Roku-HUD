sub init()
    m.top.functionName = "Run"
end sub

sub Run()
    server = Trim(m.top.serverUrl)
    path = Trim(m.top.pagesPath)
    if server = "" then
        m.top.error = "Server URL is blank"
        return
    end if
    if path = "" then path = "/api/pages"

    url = JoinUrl(server, path)
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    transfer.InitClientCertificates()

    body = transfer.GetToString()
    code = transfer.GetResponseCode()

    if code < 200 or code > 299 then
        m.top.error = "HTTP " + code.ToStr() + " from " + url
        return
    end if

    parsed = ParseJson(body)
    if parsed = invalid then
        m.top.error = "Invalid JSON from " + url
        return
    end if

    m.top.result = parsed
end sub

function JoinUrl(base as string, path as string) as string
    if Right(base, 1) = "/" and Left(path, 1) = "/" then
        return Left(base, Len(base) - 1) + path
    end if
    if Right(base, 1) <> "/" and Left(path, 1) <> "/" then
        return base + "/" + path
    end if
    return base + path
end function
