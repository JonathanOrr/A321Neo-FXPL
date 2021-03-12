

function Read_CSV(file)
  local result_full = {}
  local sep = ','

    for line in io.lines(file) do 
        local result = {}
        local pos = 1
        continue = true
        while continue do 
            local c = string.sub(line,pos,pos)
            if (c ~= "") then
                local startp,endp = string.find(line,sep,pos)
                if (startp) then 
                    table.insert(result,string.sub(line,pos,startp-1))
                    pos = endp + 1
                else
                    table.insert(result,string.sub(line,pos))
                    continue = false
                end 
            else
                continue = false 
            end
        end
        table.insert(result_full,result)
    end

    return result_full
end
