# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "HOLD_US" -parent ${Page_0}


}

proc update_PARAM_VALUE.HOLD_US { PARAM_VALUE.HOLD_US } {
	# Procedure called to update HOLD_US when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOLD_US { PARAM_VALUE.HOLD_US } {
	# Procedure called to validate HOLD_US
	return true
}


proc update_MODELPARAM_VALUE.HOLD_US { MODELPARAM_VALUE.HOLD_US PARAM_VALUE.HOLD_US } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOLD_US}] ${MODELPARAM_VALUE.HOLD_US}
}

