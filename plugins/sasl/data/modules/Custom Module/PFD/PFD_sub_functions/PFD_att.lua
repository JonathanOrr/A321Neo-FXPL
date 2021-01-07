function PFD_draw_att(PFD_table)
    --draw the mask
    sasl.gl.drawMaskStart ()
    sasl.gl.drawTexture(PFD_pitch_scale_mask, 0, 0, 900, 900, {1,1,1})
    --draw under the mask
    sasl.gl.drawUnderMask(true)
    SASL_rotated_center_img_xcenter_aligned(PFD_normal_pitch_scale, size[1]/2-55, size[2]/2-7, 2870, 779, 90 - get(PFD_table.Bank), get(PFD_table.Pitch) * 10, -779/2, {1, 1, 1})
    SASL_rotated_center_img_xcenter_aligned(PFD_static_sky, size[1]/2-55, size[2]/2-7, 1575, 779, 90 - get(PFD_table.Bank), 0, -779/2, {1, 1, 1})
    SASL_rotated_center_img_xcenter_aligned(PFD_ground, size[1]/2-55, size[2]/2-7, 2228, 779, 90 - get(PFD_table.Bank), - 187 * (1 - Math_clamp(get(PFD_table.RA_ALT)/120 + get(PFD_table.Pitch)/18, 0, 1)), -779/2, {1, 1, 1})
    --terminate masked drawing
    sasl.gl.drawMaskEnd ()

    SASL_draw_img_xcenter_aligned(PFD_pitch_wings, size[1]/2-56, size[2]/2-44, 402, 47, {1,1,1})

    SASL_draw_img_xcenter_aligned(PFD_bank_angle, size[1]/2-56, size[2]/2+158, 366, 95, {1,1,1})
end