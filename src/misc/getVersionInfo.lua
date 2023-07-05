local version = {}

local function runGit(cmd)
    local process = io.popen("git "..cmd, "r")
    if not process then 
        return nil 
    end
    local result = process:read("l")
    process:close()
    return result
end

function version.getCommit()
    return runGit("rev-parse HEAD") or "ERROR: unable to get commit info"
end

function version.getBranch()
    return runGit("rev-parse --abbrev-ref HEAD") or "ERROR: unable to get branch info"
end

function version.lastChange()
    return runGit("show -s --format=%ct HEAD") or "ERROR: unable to get branch info"
end

return version