local version = {}

function version.getCommit()
    local process = io.popen("git rev-parse --short HEAD", "r")
    if not process then 
        return nil 
    end
    local commit = process:read("a")
    process:close()
    return commit
end

return version