-- This function splits a gigantic paragraph into readable text, returns a table for each line, with key = line number.
-- The ending of the line will always be a space.

function string_slice(parag, no_of_char)
    local result = {}
    local buffer = {}
    
    for w in parag:gmatch("%S+") do 
        table.insert(buffer, w)
    end
    -- "buffer" is now a table with each character inside one cell of the array
    local assemble = ""
    local num_of_lines = 1
    local number_of_words = #buffer
    local words_in_that_line = 0
    for i=1, number_of_words do -- we need to assemble text one by one, for (number of words) times
        local test = assemble..buffer[1].." " -- test if "assemble" will exceed no_of_char if I add one more word
        if #test < no_of_char then
            assemble = assemble..buffer[1].." " -- build the word, as even after adding it it'll be less than no_of_char
            table.remove(buffer, 1) -- for every word we build, we remove it from the buffer string
            if #buffer == 0 then -- we have reached the end
                result[num_of_lines] = assemble -- insert the remaining words at the end onto the next line
            end
        else  -- if I add next word it'll be more than no_of_char
            result[num_of_lines] = assemble -- insert the assembled words into a new line
            num_of_lines = num_of_lines + 1
            assemble = ""
            
            assemble = assemble..buffer[1].." " -- after inserting the assmble into result, lets start the next assemble sequence
            table.remove(buffer, 1)
            if #buffer == 0 then -- we have reached the end
                result[num_of_lines] = assemble -- insert the remaining words at the end onto the next line
            end
        end
    end
    return result
end