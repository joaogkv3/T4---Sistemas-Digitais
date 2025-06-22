if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work


vlog FPU.v
vlog tb_FPU.v

vsim work.tb_FPU

view wave
do wave.do

run 500 us

view wave
