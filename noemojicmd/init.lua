--------------------------------------------------------------------------
--  Chatterino Lua plugin:  /ne  <text>
--  Rewrites each word so it contains an U+034F (COMBINING GRAPHEME JOINER) 
--	in its centre and sends it thus blocking any emoji
--------------------------------------------------------------------------

------------------------------------------------------------------
--  Helper UTF-8 safe insertion of U+034F in the middle of a word
------------------------------------------------------------------
local function insertUnicode(word)
    local len = utf8.len(word)
    if not len or len < 2 then       -- 1-letter or bad UTF-8 → unchanged
        return word
    end

    local mid = math.floor(len / 2)                     -- left-biased
    local left, right = "", ""
    local i = 0

    for _, code in utf8.codes(word) do
        i = i + 1
        if i <= mid then
            left  = left  .. utf8.char(code)
        else
            right = right .. utf8.char(code)
        end
    end
    return left .. "͏" .. right
end

-------------------------------------------------------
--  Command handler: called when user types  /ne …
-------------------------------------------------------
local function cmd_ne(ctx)
    -- ctx.words contains the command name itself followed by parameters
    if #ctx.words < 2 then
        ctx.channel:add_system_message("Usage: /ne <text>")
        return
    end

    -- Build the text after removing the first element (the trigger)
    local out = {}
    for i = 2, #ctx.words do
        if ctx.words[i]:sub(1,1) == "@" then
            -- If it's a mention, just keep it as is
            table.insert(out, ctx.words[i])
        else
            table.insert(out, insertUnicode(ctx.words[i]))
        end
   end
    local msg = table.concat(out, " ")

    -- Send the transformed message to the same channel
    ctx.channel:send_message(msg)
end

--------------------------------------------------
--  Register the command (returns false if name
--  already taken, in which case we just abort)
--------------------------------------------------
if not c2.register_command("/ne", cmd_ne) then
    c2.log(c2.LogLevel.Warning, "Command /ne already exists, plugin skipped.")
end
