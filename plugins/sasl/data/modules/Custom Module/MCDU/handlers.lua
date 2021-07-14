local mcdu_inp = {}

local MCDU_ENTRIES = 
{
    {
        ref_name = "key",               --the group of the command
        ref_desc = "Key",               --the description of the command
        ref_entries = MCDU_ENTRY_KEYS,  --the group of keys
        ref_callback =                  --what they should do
        function (mcdu_data, count, val)

            if mcdu_data.message_showing then
                return  -- You need to CLR the message before this
            end

            if val == "overfly" then
                val = "$"
            elseif val == "slash" then
                val = "/"
            elseif val == "space" then
                val = " "
            end

            if #mcdu_data.entry.text < 22 then
                mcdu_data.entry.text = mcdu_data.entry.text .. val
            end

        end
    },
    {
        ref_name = "page",
        ref_desc = "Page",
        ref_entries = MCDU_ENTRY_PAGES,
        ref_callback = 
        function (mcdu_data, count, val)
            mcdu_open_page(mcdu_data,count * 100)
        end
    },
    {
        ref_name = "side",
        ref_desc = "Side key",
        ref_entries = MCDU_ENTRY_SIDES,
        ref_callback = 
        function (mcdu_data, count, val)
            mcdu_pages[mcdu_data.curr_page]:press_button(mcdu_data, val)
        end
    },
    {
        ref_name = "misc",
        ref_desc = "Clear key",
        ref_entries = {"clr"},
        ref_callback = function (mcdu_data, count, val)
            mcdu_data.clear_start = get(TIME)
        end,
        ref_callback_end = 
        function (mcdu_data, count, val)
            if get(TIME) - mcdu_data.clear_start > 1 then
                return
            end
            if mcdu_data.message_showing then
                if mcdu_data.entry.text == "GPS PRIMARY" then
                    set(ND_GPIRS_indication,0)
                end
                mcdu_data.entry = mcdu_data.entry_cache
                table.remove(mcdu_data.messages)
                mcdu_data.message_showing = false
            else
                if #mcdu_data.entry.text > 0 then
                    mcdu_data.entry.text = mcdu_data.entry.text:sub(1,#mcdu_data.entry.text - 1)
                else
                    if #mcdu_data.entry.text == 0 then
                        table.insert(mcdu_data.messages, {text="CLR", color=ECAM_WHITE})
                    end
                end
            end
        end,
        ref_callback_cont = 
        function (mcdu_data, count, val)
            if get(TIME) - mcdu_data.clear_start > 1 then
                if mcdu_data.message_showing then
                    mcdu_data.entry = mcdu_data.entry_cache
                    table.remove(mcdu_data.messages)
                    mcdu_data.message_showing = false
                else
                    mcdu_data.entry = {text="", color=nil}
                end
            end

        end
    },
    {
        ref_name = "misc",
        ref_desc = "positive_negative",
        ref_entries = {"positive_negative"},
        ref_callback = 
        function (mcdu_data, count, val)
            local entry_len = #mcdu_data.entry.text
            if entry_len < 22 then
                if string.sub(mcdu_data.entry.text, entry_len, entry_len) == "-" then
                    mcdu_data.entry.text = string.sub(mcdu_data.entry.text, 0, #mcdu_data.entry.text - 1) .. "+"
                elseif string.sub(mcdu_data.entry.text, entry_len, entry_len) == "+" then
                    mcdu_data.entry.text = string.sub(mcdu_data.entry.text, 0, entry_len - 1) .. "-"
                elseif string.sub(mcdu_data.entry.text, entry_len, entry_len) ~= "+" and string.sub(mcdu_data.entry.text, entry_len, entry_len) ~= "-" then
                    mcdu_data.entry.text = mcdu_data.entry.text .. "-"
                end
            end
        end
    }
}

function init_mcdu_handlers(mcdu_data, str_suffix)
    --register all entry keys
    for i,entry_category in ipairs(MCDU_ENTRIES) do
        for count,entry in ipairs(entry_category.ref_entries) do
            mcdu_inp[entry] = createCommand("a321neo/cockpit/mcdu" .. str_suffix .. "/"  .. entry_category.ref_name .. "/" .. entry, "MCDU " .. entry .. " " .. entry_category.ref_desc)
            sasl.registerCommandHandler(mcdu_inp[entry], 0, function (phase)
                if phase == SASL_COMMAND_BEGIN and entry_category.ref_callback then
                    entry_category.ref_callback(mcdu_data, count, entry)
                elseif phase == SASL_COMMAND_CONTINUE and entry_category.ref_callback_cont then
                    entry_category.ref_callback_cont(mcdu_data, count, entry)
                elseif phase == SASL_COMMAND_END and entry_category.ref_callback_end then
                    entry_category.ref_callback_end(mcdu_data, count, entry)
                end
            end)
        end
    end
end


