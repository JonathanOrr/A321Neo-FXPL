--[[A32NX Adaptive Auto Throttle
Copyright (C) 2020 Jonathan Orr

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.]]

function update()

    if get(A32nx_autothrust_on) == 1 then

        if get(DELTA_TIME) ~= 0 then
            Smoothed_error = Set_anim_value(Smoothed_error, get(A32nx_target_spd) - get(SimDR_aircraft_ias), -1000, 1000, 12.5)
            Autothrust_output = A32nx_PID_new(A32nx_auto_thrust, Smoothed_error)
            set(SimDR_throttle, Set_linear_anim_value(get(SimDR_throttle), Autothrust_output, 0, 1, 0.5))

            ---print("P: " .. A32nx_auto_thrust.Proportional, "I: " .. A32nx_auto_thrust.Integral, "D: " .. A32nx_auto_thrust.Derivative)
        end
	end

    set(A32nx_thrust_control_output, get(SimDR_throttle))

end