--
-- Description: an enum that represents each of the "domains": client, server, and shared
--
DOMAIN_CLIENT = 1;
DOMAIN_SHARED = 2;
DOMAIN_SERVER = 3;

glua = {}

--
-- Descrpition: runs a function within a specified domain
-- Arguments:
--      number: domain (refer to DOMAIN enum)
--      function: func (whatever you want to run)
--
function glua.RunOnDomain(domain, func)
    if (domain <= DOMAIN_SHARED and CLIENT) then
        func()
    end

    if (domain >= DOMAIN_SHARED and SERVER) then
        func()
    end
end

--
-- Descrpition: Includes files within specified domain. Automatically calls include() and
--              AddCSLuaFile() where necessary
-- Arguments:
--      number: domain (refer to DOMAIN enum)
--      varargs: ... (filenames of files you want to include)
--
function glua.IncludeFiles(domain, ...)
    arg = {...}

    assert(arg[1] != nil, "Expected at least one filename, got nil")

    if (domain <= DOMAIN_SHARED and SERVER) then
        for key, filename in pairs(arg) do
            AddCSLuaFile(filename)
        end
    end

    glua.RunOnDomain(domain, function()
        for key, filename in pairs(arg) do
            include(filename)
        end
    end)
end
