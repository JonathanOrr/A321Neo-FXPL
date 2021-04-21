function update()
    FBW.lateral.protections.bank_angle_protection()
    FBW.lateral.controllers.roll_rate_PID.bumpless_transfer()
    FBW.lateral.controllers.roll_rate_PID.control()
    FBW.lateral.controllers.roll_rate_PID.bp()
    FBW.lateral.controllers.output_blending()
end
