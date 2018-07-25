DOMAIN_CLIENT = 1;
DOMAIN_SHARED = 2;
DOMAIN_SERVER = 3;

glua = {}

function glua.RunOnDomain(domain, func)
    if (domain <= DOMAIN_SHARED and CLIENT) then
        func()
    end

    if (domain >= DOMAIN_SHARED and SERVER) then
        func()
    end
end

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
