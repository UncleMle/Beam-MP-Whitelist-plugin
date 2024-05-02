print("Starting beam-mp whitelist script [Written by unclemole]");

-- [ Initilization ]
local whitelistFile = io.open("whitelist.txt", "r+");
local adminsFile = io.open("admins.txt", "r+");

local whitelistedUsers = {};
local admins = {};

if whitelistFile == nil or adminsFile == nil then
    print("Unable to create one of the files. Ensure script has elevated read & write permissions.");
end

print(whitelistFile)

for user in whitelistFile:lines() do
    table.insert(whitelistedUsers, user);
end

for admin in adminsFile:lines() do
    table.insert(admins, admin);
end

-- [ Global Methods ]
function GetUserData(username)
    local isWhitelisted = false;
    local isAdmin = false;

    for index, value in ipairs(whitelistedUsers) do
        if username == value then isWhitelisted = true end;
    end

    for index, value in ipairs(admins) do
        if username == value then isAdmin = true end;
    end

    return isWhitelisted, isAdmin;
end

function HandleWhitelistCheck(playerId, username)
    local whitelist, adminState = GetUserData(username);

    if not adminState and not whitelist then
        MP.DropPlayer(playerId, "Your not whitelisted.");
    end
end

function HandleChatMessage(playerId, username, message)
    local whitelistCommand = string.match(message, "/whitelist");
    local whitelisted, admin = GetUserData(username);

    if not whitelistCommand then return end;

    if not admin then
        NoAuthChat(playerId)
        return
    end;

    local argCount = select(2, w:gsub(" ", "")) + 1;

    if argCount < 2 then
        MP.SendChatMessage(playerId, "Missing [username] argument in command /whitelist.");
        return
    end

    local username = inputString:match("%S+%s(%S+)");

    AddWhitelist(username);

    MP.SendChatMessage(playerId, "Added " .. username .. " to the whitelist.");
end

function HandleConsoleInput(inputText)
    local commandText = inputText:find(' ')

    if not commandText then return end;

    local targetAdmin = inputText:sub(commandText + 1)

    if inputText:sub(1, commandText - 1) ~= "addadmin" then return end;

    if not targetAdmin then
        print("Enter a valid admin username to add.");
        return
    end

    AddAdmin(targetAdmin);
    print("Added admin " .. targetAdmin);
end

-- [ Utility Methods ]
function NoAuthChat(playerId)
    MP.SendChatMessage(playerId, "Your not authorized to use this!");
end

function AddWhitelist(username)
    table.insert(whitelistedUsers, username);
    whitelistFile.write(username);
end

function AddAdmin(username)
    table.insert(admins, username);
    admins.write(username);
end

-- [ Event Handlers ]
MP.RegisterEvent("onPlayerJoin", "HandleWhitelistCheck");
MP.RegisterEvent("onChatMessage", "HandleChatMessage");
MP.RegisterEvent("onConsoleInput", "HandleConsoleInput")
