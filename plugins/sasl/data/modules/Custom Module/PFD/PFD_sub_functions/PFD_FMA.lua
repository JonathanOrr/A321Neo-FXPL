function PFD_draw_FMA(fma_table)
    for i = 1, #fma_table do
        for j = 1, #fma_table[i] do
            --draw if the FMA is shown--
            if fma_table[i][j].shown() == true then
                --draw white box around the FMA--
                if fma_table[i][j].boxed == true then
                    Sasl_DrawWideFrame(fma_table[i][j].position[1], fma_table[i][j].position[2], fma_table[i][j].size[1], fma_table[i][j].size[2], 2, 2, fma_table[i][j].box_color)
                end

                --draw the FMA text--
                local function draw_fma_text()
                    local line_1_text_width, line_1_text_height = sasl.gl.measureText(Font_ECAMfont, fma_table[i][j].text_line_1, 34, false, false)
                    local line_1_y_pos

                    --center or push up the first line depending on if there is a second line
                    if fma_table[i][j].text_line_2 == nil then
                        line_1_y_pos = fma_table[i][j].position[2] + fma_table[i][j].size[2] / 2 - line_1_text_height / 2
                    else
                        line_1_y_pos = fma_table[i][j].position[2] + 3 * fma_table[i][j].size[2] / 4 - line_1_text_height / 2
                    end

                    --draw the first line--
                    sasl.gl.drawText(
                        Font_ECAMfont,
                        fma_table[i][j].position[1] + fma_table[i][j].size[1] / 2,
                        line_1_y_pos,
                        fma_table[i][j].text_line_1,
                        34,
                        false,
                        false,
                        TEXT_ALIGN_CENTER,
                        fma_table[i][j].text_color
                    )
                    --draw the second line if there are any--
                    if fma_table[i][j].text_line_2 ~= nil then
                        sasl.gl.drawText(
                            Font_ECAMfont,
                            fma_table[i][j].position[1] + fma_table[i][j].size[1] / 2,
                            fma_table[i][j].position[2] + 1 * fma_table[i][j].size[2] / 4 - line_1_text_height / 2,
                            fma_table[i][j].text_line_2,
                            34,
                            false,
                            false,
                            TEXT_ALIGN_CENTER,
                            fma_table[i][j].text_color
                        )
                    end
                end

                --draw the FMA text using the functions above or the custom fucntions
                if fma_table[i][j].text_flashing == true then
                    if Round(get(TIME) % 1) == 1 then
                        if fma_table[i][j].draw_with_function == false then
                            draw_fma_text()
                        else
                            fma_table[i][j].draw_function()
                        end
                    end
                else
                    if fma_table[i][j].draw_with_function == false then
                        draw_fma_text()
                    else
                        fma_table[i][j].draw_function()
                    end
                end

            end
        end
    end

    sasl.gl.drawWideLine(185, 900, 185, 762, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(375, 900, 375, 762, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(580, 900, 580, 762, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(755, 900, 755, 762, 4, ECAM_LINE_GREY)
end