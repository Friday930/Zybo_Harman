# 
# Synthesis run script generated by Vivado
# 

namespace eval rt {
    variable rc
}
set rt::rc [catch {
  uplevel #0 {
    set ::env(BUILTIN_SYNTH) true
    source $::env(HRT_TCL_PATH)/rtSynthPrep.tcl
    rt::HARTNDb_resetJobStats
    rt::HARTNDb_resetSystemStats
    rt::HARTNDb_startSystemStats
    rt::HARTNDb_startJobStats
    set rt::cmdEcho 0
    rt::set_parameter writeXmsg true
    rt::set_parameter enableParallelHelperSpawn true
    set ::env(RT_TMP) "C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/.Xil/Vivado-50588-DESKTOP-7CFQ9ND/realtime/tmp"
    if { [ info exists ::env(RT_TMP) ] } {
      file delete -force $::env(RT_TMP)
      file mkdir $::env(RT_TMP)
    }

    rt::delete_design

    rt::set_parameter datapathDensePacking false
    set rt::partid xc7z020clg400-1
     file delete -force synth_hints.os

    set rt::multiChipSynthesisFlow false
    source $::env(SYNTH_COMMON)/common_vhdl.tcl
    set rt::defaultWorkLibName xil_defaultlib

    set rt::useElabCache false
    if {$rt::useElabCache == false} {
      rt::read_verilog -sv {
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/DIV_GRID/AreaSel.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/VGA/Frame_Buffer.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/VGA/OV7670_MemController.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/VGA/OV7670_VGA_Display.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/VGA/QVGA_MemController.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/SCCB/SCCB_Master.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/new/TOP_Hand_Signal.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/VGA/VGA_Controller.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/DIV_GRID/hand_signal.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/DIV_GRID/print_grid.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/DIV_GRID/rgb_color_detect.sv
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/TOP/new/TOP_OV7670_HDMI.sv
    }
      rt::read_verilog {
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/SPI/SPI_Master_Top.v
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/SPI/btn_debounce.v
    }
      rt::read_vhdl -lib xil_defaultlib {
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/ClockGen.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/DVI_Constants.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/OutputSERDES.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/SyncAsync.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/ResetBridge.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/SyncAsyncReset.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/TMDS_Encoder.vhd
      C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/250718_OV7670_HDMI_V2.srcs/sources_1/HDMI/rgb2dvi.vhd
    }
      rt::filesetChecksum
    }
    rt::set_parameter usePostFindUniquification false
    set rt::top TOP_OV7670_HDMI
    rt::set_parameter enableIncremental true
    rt::set_parameter markDebugPreservationLevel "enable"
    set rt::reportTiming false
    rt::set_parameter elaborateOnly true
    rt::set_parameter elaborateRtl true
    rt::set_parameter eliminateRedundantBitOperator false
    rt::set_parameter elaborateRtlOnlyFlow true
    rt::set_parameter writeBlackboxInterface true
    rt::set_parameter merge_flipflops true
    rt::set_parameter srlDepthThreshold 3
    rt::set_parameter rstSrlDepthThreshold 4
# MODE: 
    rt::set_parameter webTalkPath {}
    rt::set_parameter synthDebugLog false
    rt::set_parameter printModuleName false
    rt::set_parameter enableSplitFlowPath "C:/working/FPAG_Harman/250718_OV7670_HDMI_V2/.Xil/Vivado-50588-DESKTOP-7CFQ9ND/"
    set ok_to_delete_rt_tmp true 
    if { [rt::get_parameter parallelDebug] } { 
       set ok_to_delete_rt_tmp false 
    } 
    if {$rt::useElabCache == false} {
        set oldMIITMVal [rt::get_parameter maxInputIncreaseToMerge]; rt::set_parameter maxInputIncreaseToMerge 1000
        set oldCDPCRL [rt::get_parameter createDfgPartConstrRecurLimit]; rt::set_parameter createDfgPartConstrRecurLimit 1
        $rt::db readXRFFile
      rt::run_rtlelab -module $rt::top
        rt::set_parameter maxInputIncreaseToMerge $oldMIITMVal
        rt::set_parameter createDfgPartConstrRecurLimit $oldCDPCRL
    }

    set rt::flowresult [ source $::env(SYNTH_COMMON)/flow.tcl ]
    rt::HARTNDb_stopJobStats
    if { $rt::flowresult == 1 } { return -code error }


  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  rt::set_parameter helper_shm_key "" 
    if { [ info exists ::env(RT_TMP) ] } {
      if { [info exists ok_to_delete_rt_tmp] && $ok_to_delete_rt_tmp } { 
        file delete -force $::env(RT_TMP)
      }
    }

    source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  } ; #end uplevel
} rt::result]

if { $rt::rc } {
  $rt::db resetHdlParse
  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  return -code "error" $rt::result
}
